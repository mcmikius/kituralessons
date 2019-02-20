#import <Foundation/Foundation.h>

#import <ScadeKit/SCDWidgetsWidget.h>
#import <ScadeKit/SCDWidgetsClickable.h>


@protocol SCDWidgetsClickable;

@class SCDWidgetsWidget;


/*PROTECTED REGION ID(f807c06bcf662fa2f2a7a3caac635c1b) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDWidgetsBitmap : SCDWidgetsWidget <SCDWidgetsClickable>


@property(nonatomic) NSString* _Nonnull content;

@property(nonatomic) NSString* _Nonnull url;

@property(nonatomic, getter=isContentPriority) BOOL contentPriority;


/*PROTECTED REGION ID(daefb56b514aa6840411d363cd3be644) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
