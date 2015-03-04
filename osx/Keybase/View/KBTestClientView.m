//
//  KBTestClientView.m
//  Keybase
//
//  Created by Gabriel on 2/12/15.
//  Copyright (c) 2015 Gabriel Handford. All rights reserved.
//

#import "KBTestClientView.h"

@interface KBTestClientView ()
@property KBRPClient *client;
@property KBButton *connectButton;
@property KBListView *infoView;
@end

@implementation KBTestClientView

- (void)viewInit {
  [super viewInit];

  GHWeakSelf gself = self;
  _connectButton = [KBButton buttonWithText:@"Connect" style:KBButtonStylePrimary];
  _connectButton.targetBlock = ^{ [gself open]; };
  [self addSubview:_connectButton];

  _infoView = [KBListView listViewWithPrototypeClass:KBLabel.class rowHeight:0];
  _infoView.layer.borderColor = [KBAppearance.currentAppearance lineColor].CGColor;
  _infoView.layer.borderWidth = 1.0;
  _infoView.cellSetBlock = ^(KBLabel *label, NSString *text, NSIndexPath *indexPath, id containingView/*NSTableView*/, BOOL dequeued) {
    [label setText:text style:KBLabelStyleDefault];
  };
  [self addSubview:_infoView];

  YOSelf yself = self;
  self.viewLayout = [YOLayout layoutWithLayoutBlock:^CGSize(id<YOLayout> layout, CGSize size) {
    CGFloat y = 20;
    y += [layout setSize:CGSizeMake(200, 0) inRect:CGRectMake(0, y, size.width, 0) view:yself.connectButton options:YOLayoutOptionsSizeToFit| YOLayoutOptionsAlignCenter].size.height + 10;

    [layout setFrame:CGRectMake(20, y, size.width - 40, size.height - y - 20) view:yself.infoView];

    return CGSizeMake(size.width, size.height);
  }];
}

- (void)open {
  _client = [[KBRPClient alloc] init];
  _client.autoRetryDisabled = YES;
  _client.delegate = self;
  [_client open];
}

- (void)close {
  [_client close];
}

- (void)RPClientDidConnect:(KBRPClient *)RPClient {
  GHWeakSelf gself = self;
  [_connectButton setText:@"Disconnect" style:KBButtonStyleDefault alignment:NSCenterTextAlignment];
  _connectButton.targetBlock = ^{ [gself close]; };
  [_infoView addObjects:@[@"Connected"]];
}

- (void)RPClientDidDisconnect:(KBRPClient *)RPClient {
  [_infoView addObjects:@[@"Disconnected"]];
  GHWeakSelf gself = self;
  [_connectButton setText:@"Connect" style:KBButtonStylePrimary alignment:NSCenterTextAlignment];
  _connectButton.targetBlock = ^{ [gself open]; };
}

- (void)RPClient:(KBRPClient *)RPClient didErrorOnConnect:(NSError *)error connectAttempt:(NSInteger)connectAttempt {
  [_infoView addObjects:@[error.localizedDescription]];
}

@end
