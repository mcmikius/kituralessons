
package com.scade.phoenix;

import android.os.AsyncTask;
import android.util.Base64;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.URL;
import java.net.URLConnection;
import java.net.HttpURLConnection;
import java.util.List;
import java.util.Map;



class Request {
    public Request(String urlString,
                   int method,
                   String login,
                   String password,
                   String[] headerKeys,
                   String[] headerValues,
                   int timeout,
                   byte[] requestBody) {
        m_urlString = urlString;
        m_method = method;
        m_login = login;
        m_password = password;
        m_headerKeys = headerKeys;
        m_headerValues = headerValues;
        m_timeout = timeout;
        m_requestBody = requestBody;
    }

    public String getUrlString() { return m_urlString; }
    public int getMethod() { return m_method; }
    public String getLogin() { return m_login; }
    public String getPassword() { return m_password; }
    public String[] getHeaderKeys() { return m_headerKeys; }
    public String[] getHeaderValues() { return m_headerValues; }
    public int getTimeout() { return m_timeout; }
    public byte[] getRequestBody() { return m_requestBody; }

    private String m_urlString;
    private int m_method;
    private String m_login;
    private String m_password;
    private String[] m_headerKeys;
    private String[] m_headerValues;
    private int m_timeout;
    private byte[] m_requestBody;
}


class SyncRequestTask extends AsyncTask<Request, Void, Response> {
    protected Response doInBackground(Request... reqs) {

        Request req = reqs[0];

        try {

            // creating connection to url

            URL url = new URL(req.getUrlString());
            HttpURLConnection con = (HttpURLConnection)url.openConnection();


            // setting request method

            String methodStr;

            switch (req.getMethod()) {
            case 0:
                methodStr = "GET";
                break;
            case 1:
                methodStr = "POST";
                break;
            case 2:
                methodStr = "PUT";
                break;
            case 3:
                methodStr = "DELETE";
                break;
            case 4:
                methodStr = "HEADER";
                break;
            default:
                android.util.Log.e("Phoenix", "Unknown HTTP method " + req.getMethod());
                return null;
            }

            con.setRequestMethod(methodStr);


            // setting auth header
            if (req.getLogin() != null) {
               String authString = req.getLogin() + ":";
               if (req.getPassword() != null) {
                   authString += req.getPassword();
               }

               byte [] data = authString.getBytes("UTF-8");
               authString = "Basic " + Base64.encodeToString(data, Base64.DEFAULT);
               con.setRequestProperty("Authorization", authString);
            }


            // setting additional headers
            if (req.getHeaderKeys() != null) {
                for (int i = 0; i < req.getHeaderKeys().length; ++i) {
                    con.setRequestProperty(req.getHeaderKeys()[i], req.getHeaderValues()[i]);
                }
            }


            // setting connection timeout
            con.setConnectTimeout(req.getTimeout());


            // writing request body if sepcified
            if (req.getRequestBody() != null) {
                OutputStream out = con.getOutputStream();
                out.write(req.getRequestBody());
                out.flush();
                out.close();
            }

            // sending request
            int respCode = con.getResponseCode();

            // reading response body
            byte[] body = readAllData(con.getInputStream());

            // reading headers
            String[] resHeaderKeys = null;
            String[] resHeaderValues = null;
            Map<String, List<String>> headers = con.getHeaderFields();

            if (headers.size() > 0) {
                resHeaderKeys = new String[headers.size()];
                resHeaderValues = new String[headers.size()];

                int idx = 0;
                for (Map.Entry<String, List<String>> entry : headers.entrySet()) {
                    resHeaderKeys[idx] = entry.getKey();

                    // headers contain the first "HTTP/X.X <N> OK" line with
                    // null key
                    if (resHeaderKeys[idx] == null) {
                        resHeaderKeys[idx] = "";
                    }

                    resHeaderValues[idx] = entry.getValue().get(0);
                    ++idx;
                }
            }

            return new Response(respCode, null, body, resHeaderKeys, resHeaderValues);

        }
        catch (java.io.IOException ex) {
            return new Response(-1, ex.getMessage(), null, null, null);
        }
    }



    // Reads all data from InputStream to byte array
    private static byte[] readAllData(InputStream istr) throws java.io.IOException {
        byte[] data = new byte[1024];
        int dataSize = 0;

        while (true) {
            int nBytesRead = istr.read(data, dataSize, data.length - dataSize);
            if (nBytesRead < 0) {
                // end of stream
                break;
            }

            dataSize += nBytesRead;

            if (dataSize == data.length) {
                data = java.util.Arrays.copyOf(data, data.length * 2);
            }
        }

        if (dataSize == 0) {
            return null;
        }

        return java.util.Arrays.copyOf(data, dataSize);
    }
}



// Wrapper class around HttpURLConnection
public class RequestService {

    // Makes sync HTTP[s] request. Returns reference to HTTP[s] response.
    public static Response syncRequest(String urlString,
                                       int method,
                                       String login,
                                       String password,
                                       String [] headerKeys,
                                       String [] headerValues,
                                       int timeout,
                                       byte [] requestBody) {

        // android does not allow network IO in the main thread by default.
        // We use AsyncTask to run in background thread

        Request req = new Request(urlString,
                                  method,
                                  login,
                                  password,
                                  headerKeys,
                                  headerValues,
                                  timeout,
                                  requestBody);
        SyncRequestTask task = new SyncRequestTask();
        task.execute(req);

        try {
            return task.get();
        }
        catch(Exception ex) {
            return new Response(-1, "Exception in AsyncTask", null, null, null);
        }
    }
}

