//
//  String_NSArrayExtension.m
//  NWFieldPicker
//
//  Created by Scott Andrew on 9/28/09.
//  Copyright 2009 New Wave Digital Media. All rights reserved.
//
//  This source code is provided under BSD license, the conditions of which are listed below. 
//
//  Redistribution and use in source and binary forms, with or without modification, are permitted 
//  provided that the following conditions are met:
//
//  • Redistributions of source code must retain the above copyright notice, this list of 
//   conditions and the following disclaimer.
//  • Redistributions in binary form must reproduce the above copyright notice, this list of conditions
//   and the following disclaimer in the documentation and/or other materials provided with the distribution.
//  • Neither the name of Positive Spin Media nor the names of its contributors may be used to endorse or 
//   promote products derived from this software without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED 
//  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A 
//  PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY 
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, 
//  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
//  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE 
//  OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH 
//  DAMAGE.
//
// This was a great find on stack overflow. Can't claim it as mine..
#import "NSString+NSArrayExtension.h"

@implementation NSString(NSArrayExtension)

+ (id)stringWithFormat:(NSString *)format array:(NSArray*) arguments;
{
    char *argList = (char *)malloc(sizeof(NSString *) * [arguments count]);
    [arguments getObjects:(id *)argList];
    NSString* result = [[NSString alloc] initWithFormat:format arguments:argList];
    free(argList);
    return [result autorelease];
}

@end
