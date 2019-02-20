#import <Foundation/Foundation.h>

#import <ScadeKit/SCDWidgetsIControl.h>


@protocol SCDSvgDrawable;
@protocol SCDWidgetsIControl;


/*PROTECTED REGION ID(094e650f4ea9f071580f608765947bc4) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@protocol SCDWidgetsIVisualControl <SCDWidgetsIControl>


@property(nonatomic) id<SCDSvgDrawable> _Nullable drawing;


- (id<SCDWidgetsIVisualControl> _Nullable)copy;


/*PROTECTED REGION ID(8f9b51eb6ea6f71b2bfa5f9c63f34125) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
