//
//  DemoHTMLCSSTextViewController.m
//  DTCoreText
//
//  Created by 黄辉 on 19/08/2017.
//  Copyright © 2017 Drobnik.com. All rights reserved.
//

#import "DemoHTMLCSSTextViewController.h"
#import "DTAttributedTextView.h"
#import "DTLinkButton.h"
#import <SDWebImage/UIImageView+WebCache.h>

#pragma mark - define

@interface DemoHTMLCSSTextViewController () <DTAttributedTextContentViewDelegate>

@property (nonatomic, weak) UIView *originView;
@property (nonatomic, strong) UIView *snapshotView;
@property (nonatomic, strong) UIView *maskView;

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
		imageView.userInteractionEnabled = YES;

		[imageView sd_setImageWithURL:attachment.contentURL
					 placeholderImage:[UIImage imageNamed:@"Oliver@2x.jpg"]
							completed:nil];

		UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImageAction:)];
		[imageView addGestureRecognizer:tap];

		return imageView;
	}

	return nil;
}

- (void)tapImageAction:(UITapGestureRecognizer *)gesture {

	UIView *originView = gesture.view;

	[UIView animateWithDuration:0.3 animations:^{
		originView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.5, 1.5);
	} completion:^(BOOL finished) {
		[UIView animateWithDuration:0.4 animations:^{
			originView.transform = CGAffineTransformIdentity;
		}];
	}];
	
}

- (UIView *)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView
			  viewForAttributedString:(NSAttributedString *)string frame:(CGRect)frame {

	NSDictionary *attributes = [string attributesAtIndex:0 effectiveRange:NULL];

	NSURL *URL = [attributes objectForKey:DTLinkAttribute];
	NSString *identifier = [attributes objectForKey:DTGUIDAttribute];

	DTLinkButton *button = [[DTLinkButton alloc] initWithFrame:frame];
	button.GUID = identifier;
	button.URL = URL;
	[button addTarget:self action:@selector(openURL:) forControlEvents:UIControlEventTouchUpInside];

	UIImage *normalImage = [attributedTextContentView contentImageWithBounds:frame options:DTCoreTextLayoutFrameDrawingDefault];
	[button setImage:normalImage forState:UIControlStateNormal];
	UIImage *highlightImage = [attributedTextContentView contentImageWithBounds:frame options:DTCoreTextLayoutFrameDrawingDrawLinksHighlighted];
	[button setImage:highlightImage forState:UIControlStateHighlighted];
	[button setImage:highlightImage forState:UIControlStateSelected];

	return button;
}

- (void)openURL:(DTLinkButton *)button {

	[[UIApplication sharedApplication] openURL:button.URL];
}

//- (BOOL)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView shouldDrawBackgroundForTextBlock:(DTTextBlock *)textBlock frame:(CGRect)frame context:(CGContextRef)context forLayoutFrame:(DTCoreTextLayoutFrame *)layoutFrame
//{
//	UIBezierPath *roundedRect = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(frame, 1, 1) cornerRadius:10];
//
//	CGColorRef color = [textBlock.backgroundColor CGColor];
//	if (color)
//	{
//		CGContextSetFillColorWithColor(context, color);
//		CGContextAddPath(context, [roundedRect CGPath]);
//		CGContextFillPath(context);
//		
//		CGContextAddPath(context, [roundedRect CGPath]);
//		CGContextSetRGBStrokeColor(context, 0, 0, 0, 1);
//		CGContextStrokePath(context);
//		return NO;
//	}
//	
//	return YES; // draw standard background
//}

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
	CGSize maxImageSize = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height);

	// example for setting a willFlushCallback, that gets called before elements are written to the generated attributed string
	void (^callBackBlock)(DTHTMLElement *element) = ^(DTHTMLElement *element) {

		// the block is being called for an entire paragraph, so we check the individual elements

		for (DTHTMLElement *oneChildElement in element.childNodes)
		{
			// if an element is larger than twice the font size put it in it's own block
//			if (oneChildElement.displayStyle == DTHTMLElementDisplayStyleInline && oneChildElement.textAttachment.displaySize.height > 2.0 * oneChildElement.fontDescriptor.pointSize)
			{
				oneChildElement.displayStyle = DTHTMLElementDisplayStyleBlock;
				oneChildElement.paragraphStyle.minimumLineHeight = element.textAttachment.displaySize.height;
				oneChildElement.paragraphStyle.maximumLineHeight = element.textAttachment.displaySize.height;
				oneChildElement.paragraphStyle.paragraphSpacingBefore = 0;
				oneChildElement.paragraphStyle.paragraphSpacing = 0;
				oneChildElement.underlineStyle = kCTUnderlineStyleNone;
			}
		}
	};

	NSMutableDictionary *options = @{
									 DTIgnoreInlineStylesOption: @NO,
									 DTDefaultLinkDecoration: @NO,
									 DTDefaultLinkColor: @"#00FF00",
									 DTLinkHighlightColorAttribute: @"#0000FF",
									 DTDefaultFontSize: @15,
									 DTDefaultFontFamily: @"Times New Roman",
									 DTDefaultFontName: @"HelveticaNeue-Light",
									 DTAttachmentParagraphSpacingAttribute: @(15),
									 DTDocumentPreserveTrailingSpaces: @(15),
									 DTMaxImageSize: [NSValue valueWithCGSize:maxImageSize],
									 DTWillFlushBlockCallBack: callBackBlock
									 }.mutableCopy;

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
	_textView.shouldDrawImages = YES;
	_textView.shouldDrawLinks = YES;
	_textView.textDelegate = self; // delegate for custom sub views

	[self.view addSubview:_textView];
}

@end
