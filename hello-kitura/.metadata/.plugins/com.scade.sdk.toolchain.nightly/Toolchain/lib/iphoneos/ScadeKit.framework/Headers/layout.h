#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, SCDLayoutLayoutSizeConstraint) {
  SCDLayoutLayoutSizeConstraintWrap_content = 0,
  SCDLayoutLayoutSizeConstraintMatch_parent = 1
};
typedef NS_ENUM(NSInteger, SCDLayoutHorizontalAlignment) {
  SCDLayoutHorizontalAlignmentLeft = 0,
  SCDLayoutHorizontalAlignmentCenter = 1,
  SCDLayoutHorizontalAlignmentRight = 2
};
typedef NS_ENUM(NSInteger, SCDLayoutVerticalAlignment) {
  SCDLayoutVerticalAlignmentTop = 0,
  SCDLayoutVerticalAlignmentMiddle = 1,
  SCDLayoutVerticalAlignmentBottom = 2
};


#import <ScadeKit/SCDLayoutNode.h>

#import <ScadeKit/SCDLayoutILayoutable.h>

#import <ScadeKit/SCDLayoutLayout.h>

#import <ScadeKit/SCDLayoutLayoutData.h>

#import <ScadeKit/SCDLayoutGridData.h>

#import <ScadeKit/SCDLayoutGridLayout.h>

#import <ScadeKit/SCDLayoutStackLayout.h>

#import <ScadeKit/SCDLayoutXYLayout.h>

#import <ScadeKit/SCDLayoutXYLayoutData.h>

#import <ScadeKit/SCDLayoutGridStyle.h>
