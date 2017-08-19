//
//  DemoHTMLCSSTextViewController.m
//  DTCoreText
//
//  Created by 黄辉 on 19/08/2017.
//  Copyright © 2017 Drobnik.com. All rights reserved.
//

#import "DemoHTMLCSSTextViewController.h"
#import "DTAttributedTextView.h"
#import <SDWebImage/UIImageView+WebCache.h>

#pragma mark - define

@interface DemoHTMLCSSTextViewController () <DTAttributedTextContentViewDelegate>

@end

@implementation DemoHTMLCSSTextViewController
{
	DTAttributedTextView *_textView;
}

#pragma mark -life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // view initialisation
    [self initPageViews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

	_textView.attributedString = [self _attributedStringForSnippet];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // data source initialization
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

#pragma mark -
#pragma mark - delegate

#pragma mark - DTAttributedTextContentViewDelegate

- (UIView *)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView viewForAttachment:(DTTextAttachment *)attachment frame:(CGRect)frame
{
	if ([attachment isKindOfClass:[DTImageTextAttachment class]])
	{

		UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
		[imageView sd_setImageWithURL:attachment.contentURL
					 placeholderImage:[UIImage imageNamed:@"Oliver@2x.jpg"]
							completed:nil];

		return imageView;
	}

	return nil;
}

#pragma mark -
#pragma mark - event response

#pragma mark - button action

#pragma mark -
#pragma mark - public method

#pragma mark -
#pragma mark - private method

- (NSAttributedString *)_attributedStringForSnippet
{
	// Load HTML data
	NSString *readmePath = [[NSBundle mainBundle] pathForResource:_fileName ofType:nil];
	NSString *html = [NSString stringWithContentsOfFile:readmePath encoding:NSUTF8StringEncoding error:NULL];
	NSData *data = [html dataUsingEncoding:NSUTF8StringEncoding];

	// Create attributed string from HTML
	CGSize maxImageSize = CGSizeMake(self.view.bounds.size.width - 10.0, self.view.bounds.size.height - 10.0);

	// example for setting a willFlushCallback, that gets called before elements are written to the generated attributed string
	void (^callBackBlock)(DTHTMLElement *element) = ^(DTHTMLElement *element) {

		// the block is being called for an entire paragraph, so we check the individual elements

		for (DTHTMLElement *oneChildElement in element.childNodes)
		{
			// if an element is larger than twice the font size put it in it's own block
			if (oneChildElement.displayStyle == DTHTMLElementDisplayStyleInline && oneChildElement.textAttachment.displaySize.height > 2.0 * oneChildElement.fontDescriptor.pointSize)
			{
				oneChildElement.displayStyle = DTHTMLElementDisplayStyleBlock;
				oneChildElement.paragraphStyle.minimumLineHeight = element.textAttachment.displaySize.height;
				oneChildElement.paragraphStyle.maximumLineHeight = element.textAttachment.displaySize.height;
			}
		}
	};

	NSMutableDictionary *options = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:1.0], NSTextSizeMultiplierDocumentOption, [NSValue valueWithCGSize:maxImageSize], DTMaxImageSize,
									@"Times New Roman", DTDefaultFontFamily,  @"purple", DTDefaultLinkColor, @"red", DTDefaultLinkHighlightColor, callBackBlock, DTWillFlushBlockCallBack, nil];

	[options setObject:[NSURL fileURLWithPath:readmePath] forKey:NSBaseURLDocumentOption];

	NSAttributedString *string = [[NSAttributedString alloc] initWithHTMLData:data options:options documentAttributes:NULL];

	return string;
}

#pragma mark - request method

#pragma mark - navigation

#pragma mark -
#pragma mark - initialization

#pragma mark - getter

#pragma mark - pageViewsInit
- (void)initPageViews {

	// Create text view
	_textView = [[DTAttributedTextView alloc] initWithFrame:self.view.bounds];

	// we draw images and links via subviews provided by delegate methods
	_textView.shouldDrawImages = NO;
	_textView.shouldDrawLinks = NO;
	_textView.textDelegate = self; // delegate for custom sub views

	[self.view addSubview:_textView];
}

@end
