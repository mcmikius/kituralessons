#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, SCDCoreNotificationType) {
  SCDCoreNotificationTypeSet = 1,
  SCDCoreNotificationTypeUnset = 2,
  SCDCoreNotificationTypeAdd = 3,
  SCDCoreNotificationTypeRemove = 4,
  SCDCoreNotificationTypeMove = 5,
  SCDCoreNotificationTypeAdd_many = 6,
  SCDCoreNotificationTypeRemove_many = 7
};


#import <ScadeKit/SCDCoreAdapter.h>

#import <ScadeKit/SCDCoreNotification.h>


#import <ScadeKit/SCDCoreResource.h>

#import <ScadeKit/SCDCoreXmiResource.h>

#import <ScadeKit/SCDCoreResourceSet.h>
