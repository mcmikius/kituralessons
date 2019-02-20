//
//  runtime.h
//  ScadeSDK
//
//  Created by Grigory Markin on 02/02/16.
//  Copyright © 2016 Scade. All rights reserved.
//
#import <ScadeKit/ScadeKit-Defs.h>
#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@class EObject;
@class EPackage;
@class EClass;
@class EStructuralFeature;
@class SCDLatticeSystem;


SCADE_API
@interface SCDApplication: NSObject

- (void) onEnterBackground;

- (void) onEnterForeground;

- (void) onFinishLaunching;

- (void) launch;

@end


SCADE_API
@interface SCDRuntime : NSObject

+ (void)initRuntime:(SCDApplication*)app;

+ (EPackage*)loadMetaModel:(NSString*)relativePath;

+ (EObject*)loadResource:(NSString*)relativePath;

+ (EObject*)loadTemplate:(NSString*)name;

+ (EObject*)loadDocument:(NSString*)relativePath;

+ (void)saveDocument:(NSString*)relativePath document:(EObject*)eObject;

+ (void)saveFile:(NSString*)relativePath content:(NSString*)data;

+ (void)saveFile:(NSString*)relativePath data:(NSData*)data;

+ (NSData*)loadFile:(NSString*)relativePath;

+ (void)callWithDelay:(double)seconds closure:(void (^)())block;

+ (SCDLatticeSystem*)getSystem;

//#if DEBUG
+ (EObject*)parseSvg:(NSString*)relativePath;

//+(void) renderSvg:(EObject*)object rect:(CGRect) rectangle;
+ (void)renderSvg:(EObject*)object
                x:(double)xValue
                y:(double)yValue
             size:(CGSize)sizeValue;
//#endif //DEBUG

+ (EClass*)getEClassFor:(Class)cls;

+ (EObject*)clone:(EObject*)object;

@end


SCADE_API
@interface SCDDisplay : NSObject

+ (CGSize)getSize;

+ (void)frameChanged:(CGSize)size;

@end


// TODO: Notifcation API
/*
typedef NS_ENUM(NSInteger, SCDNotificationType) {
  SCD_NOTIFICATION_CREATE, // deprecated
  SCD_NOTIFICATION_SET,
  SCD_NOTIFICATION_UNSET,
  SCD_NOTIFICATION_ADD,
  SCD_NOTIFICATION_REMOVE,
  SCD_NOTIFICATION_ADD_MANY,
  SCD_NOTIFICATION_REMOVE_MANY,
  SCD_NOTIFICATION_MOVE,
  SCD_NOTIFICATION_REMOVING_ADAPTER,
  SCD_NOTIFICATION_RESOLVE,
  SCD_NOTIFICATION_EVENT_TYPE_COUNT,
  SCD_NOTIFICATION_UNKNOWN
};


SCADE_API
@interface SCDNotification : NSObject

- (instancetype)init NS_UNAVAILABLE;

@property(nonatomic, readonly) EObject* notifier;

@property(nonatomic, readonly) EStructuralFeature* feature;

@property(nonatomic, readonly) SCDNotificationType type;

@property(nonatomic, readonly) id value;

@property(nonatomic, readonly) id oldValue;

@property(nonatomic, readonly) NSUInteger position;

@property(nonatomic, readonly) id key;

@end


SCADE_API
@interface SCDNotificationAdapter : NSObject

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithHandler:(void (^)(SCDNotification*))_;
@end

*/
