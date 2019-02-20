#import <Foundation/Foundation.h>

#import <ScadeKit/SCDSvgElement.h>


@protocol SCDSvgElement;
@protocol SCDSvgDrawable;


/*PROTECTED REGION ID(83a8e201abf892400a5ce0b234f3570e) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDSvgContainerElement : EObject <SCDSvgElement>


@property(nonatomic) NSArray<id<SCDSvgElement>>* _Nonnull children;

@property(nonatomic) NSArray<id<SCDSvgElement>>* _Nonnull descriptiveChilds;

@property(nonatomic) NSArray<id<SCDSvgDrawable>>* _Nonnull drawableChilds;


/*PROTECTED REGION ID(0d21afb17c02501a88f43ea12fc79c8b) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
