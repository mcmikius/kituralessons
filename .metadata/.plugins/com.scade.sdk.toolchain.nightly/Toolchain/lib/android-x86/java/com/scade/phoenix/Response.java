
package com.scade.phoenix;


// Network request response
public class Response {

    public Response(int code,
                    String msg,
                    byte[] body,
                    String[] headerKeys,
                    String[] headerValues) {

        m_statusCode = code;
        m_statusMessage = msg;
        m_responseBody = body;
        m_headerKeys = headerKeys;
        m_headerValues = headerValues;
    }

    public int getStatusCode() {
        return m_statusCode;
    }

    public String getStatusMessage() {
        return m_statusMessage;
    }

    public byte[] getResponseBody() {
        return m_responseBody;
    }

    public String[] getHeaderKeys() {
        return m_headerKeys;
    }

    public String[] getHeaderValues() {
        return m_headerValues;
    }


    private int m_statusCode = -1;
    private String m_statusMessage = null;
    private byte[] m_responseBody = null;
    private String[] m_headerKeys = null;
    private String[] m_headerValues = null;
}
