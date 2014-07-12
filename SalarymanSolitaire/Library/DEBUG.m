//
//  DEBUG.m
//  SalarymanSolitaire
//
//  Created by i-chou on 7/12/14.
//  Copyright (c) 2014 i-chou All rights reserved.
//

#import "DEBUG.h"

#define CLEAR   [UIColor clearColor]
#define RED     [UIColor redColor]
#define GREEN   [UIColor greenColor]
#define BLUE    [UIColor blueColor]
#define YELLOW  [UIColor yellowColor]


UIColor *
DCOLOR()
{
    UIColor *color = CLEAR;
#ifndef NDEBUG
    static int choice = 0;
    switch (choice % 4) {
    case 0:
            color = RED;
            break;
    case 1:
            color = GREEN;
            break;
    case 2:
            color = BLUE;
            break;
    case 3:
            color = YELLOW;
            break;
    default:
            color = CLEAR;
    }
    choice += 1;
#endif
    return color;
}
