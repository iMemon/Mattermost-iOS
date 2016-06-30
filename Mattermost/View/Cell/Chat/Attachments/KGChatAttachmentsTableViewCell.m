//
//  KGChatAttachmentsTableViewCell.m
//  Mattermost
//
//  Created by Igor Vedeneev on 14.06.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

#import "KGChatAttachmentsTableViewCell.h"
#import <Masonry/Masonry.h>
#import "UIFont+KGPreparedFont.h"
#import "UIColor+KGPreparedColor.h"
#import <ActiveLabel/ActiveLabel-Swift.h>
#import "KGPost.h"
#import "KGUser.h"
#import "NSDate+DateFormatter.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "NSString+HeightCalculation.h"
#import "KGImageCell.h"
#import "KGFile.h"
#import "UIImage+Resize.h"
#import "KGFileCell.h"
#import "KGUIUtils.h"

#define KG_CONTENT_WIDTH  CGRectGetWidth([UIScreen mainScreen].bounds) - 61.f
#define KG_IMAGE_HEIGHT  (CGRectGetWidth([UIScreen mainScreen].bounds) - 61.f) * 0.66f
#define KG_FILE_HEIGHT  55.f
@interface KGChatAttachmentsTableViewCell () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy)   NSArray *files;
@end

@implementation KGChatAttachmentsTableViewCell

#pragma mark - Init

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        [self setupTableView];
    }
    
    return self;
}



#pragma mark - Setup

- (void)setupTableView {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.scrollsToTop = NO;
    self.tableView.scrollEnabled = NO;
    self.tableView.layer.drawsAsynchronously = YES;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.contentView addSubview:self.tableView];
    
    [self.tableView registerClass:[KGImageCell class] forCellReuseIdentifier:[KGImageCell reuseIdentifier]];
    [self.tableView registerClass:[KGFileCell class] forCellReuseIdentifier:[KGFileCell reuseIdentifier]];
    self.backgroundColor = [UIColor kg_whiteColor];
}


#pragma mark - Configuration

- (void)configureWithObject:(id)object {
    if ([object isKindOfClass:[KGPost class]]) {
        [super configureWithObject:object];
        
        self.files = [self.post sortedFiles];
        [self.tableView reloadData];
        
        self.backgroundColor = self.post.isUnread ? [UIColor kg_lightLightGrayColor] : [UIColor kg_whiteColor];
    }
}


#pragma mark - Height

+ (CGFloat)heightWithObject:(id)object {
    if ([object isKindOfClass:[KGPost class]]) {
        KGPost *post = object;
        CGFloat heightCell = [super heightWithObject:object];
        heightCell += tableViewHeight(post.files.allObjects);

        return  ceilf(heightCell + 8);
    }
    
    return 0.f;
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.files.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.files[indexPath.row] isImage]){
        KGImageCell *cell = [tableView dequeueReusableCellWithIdentifier:[KGImageCell reuseIdentifier] forIndexPath:indexPath];
    
        KGFile *file = self.files[indexPath.row];
        [cell configureWithObject:file];
        return cell;
    } else {
        KGFileCell *cell = [tableView dequeueReusableCellWithIdentifier:[KGFileCell reuseIdentifier] forIndexPath:indexPath];
        KGFile *file = self.files[indexPath.row];
        
        [cell configureWithObject:file];;
        return cell;
    }
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.files[indexPath.row] isImage]){
        return ceilf(KG_IMAGE_HEIGHT);
    } else {
        return ceilf(KG_FILE_HEIGHT);
    }
    
    return 0.0001;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    KGFile *file = self.files[indexPath.row];
    
    if (file.isImage) {
        if (self.photoTapHandler) {
            self.photoTapHandler(indexPath.row, ((KGImageCell *)[self.tableView cellForRowAtIndexPath:indexPath]).kg_imageView);
        }
    } else {
        if (self.fileTapHandler) {
            self.fileTapHandler(indexPath.row);
        }
    }
}


#pragma mark - Override

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat bottomYCoordOfMessage = ceilf(self.messageLabel.frame.size.width) > 0 ? self.messageLabel.frame.origin.y + self.messageLabel.frame.size.height : self.messageLabel.frame.origin.y;
    CGFloat xCoordOfMessage = self.messageLabel.frame.origin.x;
    CGFloat width = KGScreenWidth() - 61;
    self.tableView.frame = CGRectMake(xCoordOfMessage, bottomYCoordOfMessage + 8, width, tableViewHeight(self.files));
}

- (void)prepareForReuse {
    [super prepareForReuse];
}

CGFloat tableViewHeight(NSArray *files) {
    CGFloat heightImage;
    for (KGFile *file in files) {
        if ([file isImage]){
            heightImage +=  KG_IMAGE_HEIGHT;
        } else {
            heightImage +=  KG_FILE_HEIGHT;
        }
    }

    return heightImage;
}

@end
