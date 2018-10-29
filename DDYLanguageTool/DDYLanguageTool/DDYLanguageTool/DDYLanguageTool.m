#import "DDYLanguageTool.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

#define DDYLanguages @"DDYLanguages"

NSString *const DDY_ZHS = @"zh-Hans";
NSString *const DDY_EN  = @"en";
NSString *const DDY_ZHT = @"zh-Hant";
NSString *const DDY_JA  = @"ja";
NSString *const DDY_FR  = @"fr";
NSString *const DDY_DE  = @"de";
NSString *const DDY_KO  = @"ko";

NSErrorDomain DDYLanguageErrorDomain = @"DDYLanguageErrorDomain";

static inline void ddy_Swizzle(Class class, SEL originalSelector, SEL swizzledSelector) {
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    if (class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))) {
        class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

@implementation NSBundle (DDYLanguage)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ddy_Swizzle([self class], @selector(localizedStringForKey:value:table:), @selector(ddyLanguageLocalizedStringForKey:value:table:));
    });
}

- (NSString *)ddyLanguageLocalizedStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)tableName {
    NSString *language = [[NSUserDefaults standardUserDefaults] objectForKey:DDYLanguages];
    if (language && ![self.bundlePath hasSuffix:@".lproj"]) {
        NSBundle *languageBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:language ofType:@"lproj"]];
        if (languageBundle) return [languageBundle ddyLanguageLocalizedStringForKey:key value:value table:tableName];
    }
    return [self ddyLanguageLocalizedStringForKey:key value:value table:tableName];
}

- (void)dealloc {
    objc_removeAssociatedObjects(self);
}

@end

@implementation DDYLanguageTool

#pragma mark - 类方法
#pragma mark 手机系统语言
+ (NSString *)ddy_SystemLanguage {
    return [[NSLocale preferredLanguages] objectAtIndex:0];
}

#pragma mark App应用语言
+ (NSString *)ddy_AppLanguage {
    NSString *AppLanguage = [[NSUserDefaults standardUserDefaults] objectForKey:DDYLanguages];
    return AppLanguage ? AppLanguage : [self ddy_SystemLanguage];
}

#pragma mark 设置语言 nil:跟随系统 language:相应语言
+ (void)ddy_SetLanguage:(NSString *)language complete:(void (^)(NSError *))complete {
    NSError *languageError;
    NSBundle *languageBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:language ofType:@"lproj"]];
    if (languageBundle) {
        if (language) {
            [[NSUserDefaults standardUserDefaults] setObject:language forKey:DDYLanguages];
            languageError = [NSError errorWithDomain:DDYLanguageErrorDomain code:kDDYLanguageErrorUnsupport userInfo:@{@"reason":@"Success"}];
        } else {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:DDYLanguages];
            languageError = [NSError errorWithDomain:DDYLanguageErrorDomain code:kDDYLanguageErrorNil userInfo:@{@"reason":@"Remove language setting"}];
        }
    } else {
        languageError = [NSError errorWithDomain:DDYLanguageErrorDomain code:kDDYLanguageErrorUnsupport userInfo:@{@"reason":@"Unsupported language"}];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    if (complete) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            complete(languageError);
        });
    }
}

@end
