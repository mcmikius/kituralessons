#import <Foundation/Foundation.h>

#import <ScadeKit/SCDWidgetsIVisualControl.h>


@protocol SCDWidgetsIStyle;
@protocol SCDWidgetsIVisualControl;

@class SCDWidgetsPage;
@class EClass;


/*PROTECTED REGION ID(3bb4b8e89e7ed7d5124f8ac034722ed3) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@protocol SCDWidgetsIStyledControl <SCDWidgetsIVisualControl>


@property(nonatomic) NSArray<id<SCDWidgetsIStyle>>* _Nonnull styles;


- (id<SCDWidgetsIStyle> _Nullable)getStyle:(EClass* _Nullable)style;

- (SCDWidgetsPage* _Nullable)getPage;


/*PROTECTED REGION ID(c565c627c9bf0ddbf09c91c3bec93f48) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
