//
//  CJWWebView+HackishAccessoryHiding.m
//
//  Created by Caesar Wirth on 3/30/15.
//  Copyright (c) 2015 Caesar Wirth. All rights reserved.
//

#import <objc/runtime.h>
#import "CJWWebView+HackishAccessoryHiding.h"

@implementation UIWebView (HackishAccessoryHiding)

static const char * const hackishFixClassName = "UIWebBrowserViewMinusView";
static Class hackishFixClass = Nil;

- (UIView *)cjw_inputView {
    return objc_getAssociatedObject(self, @selector(cjw_inputView));
}

- (void)setCjw_inputView:(UIView *)view {
    objc_setAssociatedObject(self, @selector(cjw_inputView), view, OBJC_ASSOCIATION_RETAIN);

    UIView *browserView = [self hackishlyFoundBrowserView];
    if (browserView == nil) {
        return;
    }
    [self ensureHackishSubclassExistsOfBrowserViewClass:[browserView class]];

    object_setClass(browserView, hackishFixClass);

    // This is how we will return the accessory view if we want to
    // Class normalClass = objc_getClass("UIWebBrowserView");
    // object_setClass(browserView, normalClass);

    [browserView reloadInputViews];
}

- (UIView *)hackishlyFoundBrowserView {
    UIScrollView *scrollView = self.scrollView;
    
    UIView *browserView = nil;
    for (UIView *subview in scrollView.subviews) {
        NSString *className = NSStringFromClass([subview class]);
        if ([className containsString:@"UI"] && [className containsString:@"Web"] && [className containsString:@"Browser"] && [className containsString:@"View"]) {
            browserView = subview;
            break;
        }
    }
    return browserView;
}

- (id)methodReturningCustomInputView {
    UIView *view = self;
    UIView *customInputView = nil;

    while (view && ![view isKindOfClass:[UIWebView class]]) {
        view = view.superview;
    }

    if ([view isKindOfClass:[UIWebView class]]) {
        UIWebView *webView = (UIWebView*)view;
        customInputView = [webView cjw_inputView];
    }

    return customInputView;
}

- (id)methodInputAccessoryView {
    return nil;
}
- (void)ensureHackishSubclassExistsOfBrowserViewClass:(Class)browserViewClass {
    if (!hackishFixClass) {
        Class newClass = objc_allocateClassPair(browserViewClass, hackishFixClassName, 0);
        newClass = objc_allocateClassPair(browserViewClass, hackishFixClassName, 0);
        IMP nilImp = [self methodForSelector:@selector(methodReturningCustomInputView)];
        class_addMethod(newClass, @selector(inputView), nilImp, "@@:");
        IMP nilImp1 = [self methodForSelector:@selector(methodInputAccessoryView)];
        class_addMethod(newClass, @selector(inputAccessoryView), nilImp1, "@@:");
        objc_registerClassPair(newClass);
        
        hackishFixClass = newClass;
    }
}

@end
