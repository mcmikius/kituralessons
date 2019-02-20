#import <Foundation/Foundation.h>

#import <ScadeKit/SCDSvgElement.h>
#import <ScadeKit/SCDSvgTransformable.h>
#import <ScadeKit/SCDSvgAnimatable.h>
#import <ScadeKit/SCDSvgTouchReceiver.h>
#import <ScadeKit/SCDLayoutNode.h>
#import <ScadeKit/SCDSvgAccessibility.h>


@protocol SCDSvgElement;
@protocol SCDSvgTransformable;
@protocol SCDSvgAnimatable;
@protocol SCDSvgTouchReceiver;
@protocol SCDLayoutNode;
@protocol SCDSvgAccessibility;

@class SCDSvgDrawableHandler;
@class SCDGraphicsRectangle;


/*PROTECTED REGION ID(deab4925336920348acdc8070ad0a4c1) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@protocol
    SCDSvgDrawable <SCDSvgElement, SCDSvgTransformable, SCDSvgAnimatable,
                    SCDSvgTouchReceiver, SCDLayoutNode, SCDSvgAccessibility>


@property(nonatomic, getter=isVisible) BOOL visible;

@property(nonatomic) NSArray<SCDSvgDrawableHandler*>* _Nonnull onRendered;


- (SCDGraphicsRectangle* _Nonnull)getBoundingBox;


/*PROTECTED REGION ID(bb9b52db3a5637c7dad171cdba1e2f98) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
