//
//  SSShopView.m
//  SalarymanSolitaire
//
//  Created by IfelseGo on 14-4-14.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import "SSShopView.h"
#import "SSProductItemCell.h"
#import "SSProductCell.h"
#import <StoreKit/StoreKit.h>
#import "PurchaseManager.h"

@interface SSShopView ()
{
    UITableView                         *_shopView;
    NSArray                             *_products;
    NSMutableArray                      *_contents;
}
@end

#define kShopViewCellItemIdentifier     @"SSProductItemCell"
#define kShopViewTopCellIdentifier      @"SSProductCell"
#define kShopViewTopPowerCellIdentifier @"SSProductCellPower"
#define kShopViewFooterViewHeight       20.0f


enum { ShopViewSectionDrink, ShopViewSectionPower, ShopViewSectionYamafuda, ShopViewSectionTotal };
@implementation SSShopView

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)setProducts:(NSArray *)products;
{
    _products = products;
    _contents = [NSMutableArray arrayWithCapacity:3];
    NSMutableArray *array = nil;

    // 栄養剤
    array = [NSMutableArray array];
    [array addObject:[self productWithIdentifier:kProductIdentifierDrink3]];
    [array addObject:[self productWithIdentifier:kProductIdentifierDrink20]];
    [array addObject:[self productWithIdentifier:kProductIdentifierDrink50]];
    [_contents addObject:array];
    
    // 体力＋１
    array = [NSMutableArray array];
    [array addObject:[self productWithIdentifier:kProductIdentifierPowerUp1]];
    [array addObject:[self productWithIdentifier:kProductIdentifierPowerUp2]];
    [array addObject:[self productWithIdentifier:kProductIdentifierPowerUp3]];
    [array addObject:[self productWithIdentifier:kProductIdentifierPowerUp4]];
    [array addObject:[self productWithIdentifier:kProductIdentifierPowerUp5]];
    [_contents addObject:array];
    
    // 山札戻し
    array = [NSMutableArray array];
    [array addObject:[self productWithIdentifier:kProductIdentifierYamafuda5]];
    [array addObject:[self productWithIdentifier:kProductIdentifierYamafuda30]];
    [array addObject:[self productWithIdentifier:kProductIdentifierYamafuda60]];
    [_contents addObject:array];
}

- (SKProduct *)productWithIdentifier:(NSString *)identifier
{
    __block NSInteger index;
    [_products enumerateObjectsUsingBlock:^(SKProduct *object, NSUInteger idx, BOOL *stop) {
        if ([object.productIdentifier isEqualToString:identifier]) {
            index = idx;
            *stop = YES;
        }
    }];
    return [_products objectAtIndex:index];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.blurEffectEnabled = NO;
    // ビュー作成
    _shopView = [[UITableView alloc] initWithFrame:[self popupContentRect]];
    _shopView.backgroundColor = [UIColor clearColor];
    _shopView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _shopView.delegate = self;
    _shopView.dataSource = self;
    _shopView.rowHeight = 60.0f;
    UINib *nib = nil;
    nib = [UINib nibWithNibName:kShopViewCellItemIdentifier bundle:nil];
    [_shopView registerNib:nib forCellReuseIdentifier:kShopViewCellItemIdentifier];

    nib = [UINib nibWithNibName:kShopViewTopPowerCellIdentifier bundle:nil];
    [_shopView registerNib:nib forCellReuseIdentifier:kShopViewTopPowerCellIdentifier];
    
    nib = [UINib nibWithNibName:kShopViewTopCellIdentifier bundle:nil];
    [_shopView registerNib:nib forCellReuseIdentifier:kShopViewTopCellIdentifier];

    [self.popView addSubview:_shopView];
    
    // 商品表示
    [_shopView reloadData];
}

#pragma mark - UITableView

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == ShopViewSectionYamafuda) {
        return kShopViewFooterViewHeight;
    }
    return 0.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section != ShopViewSectionYamafuda) {
        return nil;
    }
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, kShopViewFooterViewHeight)];
    return footer;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    if (section == ShopViewSectionPower) {
        return 2;
    } else {
        return 4;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        if (indexPath.section == ShopViewSectionPower) {
            return 88.0f;
        } else {
            return 78.0f;
        }
    } else {
        return 60.0f;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (indexPath.row == 0) {
        return [self tableView:tableView titleCellForRowAtIndexPath:indexPath];
    } else {
        return [self tableView:tableView itemCellForRowAtIndexPath:indexPath];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView titleCellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    NSString *identifier;
    if (indexPath.section == ShopViewSectionPower) {
        identifier = kShopViewTopPowerCellIdentifier;
    } else {
        identifier = kShopViewTopCellIdentifier;
    }
    SSProductCell *cell = (SSProductCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    switch (indexPath.section) {
        case ShopViewSectionDrink:
            cell.type = ProductItemTypeDring;
            break;
        case ShopViewSectionPower:
            cell.type = ProductItemTypePower;
            break;
        case ShopViewSectionYamafuda:
            cell.type = ProductItemTypeYamafuda;
            break;
        default:
            break;
    }
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView itemCellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    SSProductItemCell *cell = (SSProductItemCell *)[tableView dequeueReusableCellWithIdentifier:kShopViewCellItemIdentifier];
    NSArray *products = [_contents objectAtIndex:indexPath.section];
    SKProduct *product = [products objectAtIndex:indexPath.row - 1];
    
    switch (indexPath.section) {
        case ShopViewSectionDrink:
            cell.type = ProductItemTypeDring;
            break;
        case ShopViewSectionPower:
            cell.type = ProductItemTypePower;
            break;
        case ShopViewSectionYamafuda:
            cell.type = ProductItemTypeYamafuda;
            break;
        default:
            break;
    }
    cell.identifier = [product productIdentifier];
    cell.itemName = product.localizedTitle;
    cell.itemPrice = [product localizedPrice];
    cell.lastRow = ([products count] == indexPath.row);
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;              // Default is 1 if not implemented
{
    return ShopViewSectionTotal;
}


@end