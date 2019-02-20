#import <Foundation/Foundation.h>

#import <ScadeKit/ScadeKit-Defs.h>


@class EClass;
@class EStructuralFeature;
@class EReference;
@class EOperation;


/*PROTECTED REGION ID(461727819de95e4087c54d95ce5f63a6) ENABLED START*/
#ifdef __linux__
#define NSObjectProtocol SF_NSObject
#else
#define NSObjectProtocol NSObject
#endif
/*PROTECTED REGION END*/

SCADE_API
@protocol EObject <NSObjectProtocol>
@end

SCADE_API
@interface EObject : NSObject <EObject>


- (EClass* _Nullable)eClass;

- (BOOL)eIsProxy;

- (EObject* _Nullable)eContainer;

- (EStructuralFeature* _Nullable)eContainingFeature;

- (EReference* _Nullable)eContainmentFeature;

- (NSArray<EObject*>* _Nonnull)eContents;

- (NSArray<EObject*>* _Nonnull)eCrossReferences;

- (id _Nullable)eGetWithFeature:(EStructuralFeature* _Nullable)feature
    __attribute__((swift_name("eGet(feature:)")));

- (id _Nullable)eGetWithFeatureName:(NSString* _Nonnull)featureName
    __attribute__((swift_name("eGet(featureName:)")));

- (id _Nullable)eGet:(EStructuralFeature* _Nullable)feature
             resolve:(BOOL)resolve;

- (void)eSetWithFeature:(EStructuralFeature* _Nullable)feature
               newValue:(id _Nullable)newValue
    __attribute__((swift_name("eSet(feature:newValue:)")));

- (void)eSetWithFeatureName:(NSString* _Nonnull)featureName
                   newValue:(id _Nullable)newValue
    __attribute__((swift_name("eSet(featureName:newValue:)")));

- (BOOL)eIsSet:(EStructuralFeature* _Nullable)feature;

- (void)eUnset:(EStructuralFeature* _Nullable)feature;

- (id _Nullable)eInvokeWithOperation:(EOperation* _Nullable)operation
                           arguments:(NSArray<id>* _Nonnull)arguments
    __attribute__((swift_name("eInvoke(operation:arguments:)")));

- (id _Nullable)eInvokeWithOperationName:(NSString* _Nonnull)operationName
                               arguments:(NSArray<id>* _Nonnull)arguments
    __attribute__((swift_name("eInvoke(operationName:arguments:)")));


/*PROTECTED REGION ID(e698ed8fb4f28923ec34b85fb1519591) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
