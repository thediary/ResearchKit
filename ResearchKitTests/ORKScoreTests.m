/*
 Copyright (c) 2017, The Diary Corporation. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 1.  Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 2.  Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation and/or
 other materials provided with the distribution.
 
 3.  Neither the name of the copyright holder(s) nor the names of any contributors
 may be used to endorse or promote products derived from this software without
 specific prior written permission. No license is granted to the trademarks of
 the copyright holders even if such marks are included in this software.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */


@import XCTest;
@import ResearchKit;
@import ResearchKit.Private;

@interface ORKScoreTests : XCTestCase

@end

@implementation ORKScoreTests

- (void)testTotalScoreSum {
    ORKStep *instructionStep = [[ORKInstructionStep alloc] initWithIdentifier:@"instructionStep"];
    instructionStep.staticScoreValue = 2;
    
    ORKStep *booleanStep = [ORKQuestionStep questionStepWithIdentifier:@"booleanStep"
                                                                 title:nil
                                                                answer:[ORKAnswerFormat booleanAnswerFormat]];
    booleanStep.staticScoreValue = 4;
    
    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:@"task"
                                                                steps:@[instructionStep, booleanStep]];
    
    ORKBooleanQuestionResult *booleanResult = [[ORKBooleanQuestionResult alloc] initWithIdentifier:@"booleanStep"];
    booleanResult.booleanAnswer = @(YES);
    
    ORKStepResult *booleanStepResult = [[ORKStepResult alloc] initWithStepIdentifier:@"booleanStep"
                                                                             results:@[booleanResult]];
    
    ORKStepResult *instructionStepResult = [[ORKStepResult alloc] initWithStepIdentifier:@"instructionStep"
                                                                                 results:@[]];
    
    
    ORKTaskResult *taskResult = [[ORKTaskResult alloc] initWithIdentifier:@"taskResult"];
    taskResult.results = @[instructionStepResult, booleanStepResult];
    
    NSError *error = nil;
    NSNumber *totalScore = [task totalScoreWithTaskResult:taskResult
                                         expressionFormat:nil
                                                    error:&error];
    XCTAssertNil(error);
    XCTAssertEqual(totalScore.doubleValue, 6);
}

- (void)testTotalScoreExpressionFormat {
    ORKStep *instructionStep = [[ORKInstructionStep alloc] initWithIdentifier:@"instructionStep"];
    instructionStep.staticScoreValue = 2;
    
    ORKStep *booleanStep = [ORKQuestionStep questionStepWithIdentifier:@"booleanStep"
                                                                 title:nil
                                                                answer:[ORKAnswerFormat booleanAnswerFormat]];
    booleanStep.staticScoreValue = 4;
    
    booleanStep.dynamicScoreValueBlock = ^ double (ORKStepResult *stepResult) {
        ORKResult *result = stepResult.firstResult;
        if ([result isKindOfClass:[ORKBooleanQuestionResult class]]) {
            ORKBooleanQuestionResult *booleanResult = (ORKBooleanQuestionResult *)result;
            if (booleanResult.booleanAnswer.boolValue) {
                return 2;
            }
            return 1;
        }
        return 0;
    };
    
    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:@"task"
                                                                steps:@[instructionStep, booleanStep]];
    
    ORKBooleanQuestionResult *booleanResult = [[ORKBooleanQuestionResult alloc] initWithIdentifier:@"booleanStep"];
    booleanResult.booleanAnswer = @(YES);
    
    ORKStepResult *booleanStepResult = [[ORKStepResult alloc] initWithStepIdentifier:@"booleanStep"
                                                                             results:@[booleanResult]];
    
    ORKStepResult *instructionStepResult = [[ORKStepResult alloc] initWithStepIdentifier:@"instructionStep"
                                                                                 results:@[]];
    
    ORKTaskResult *taskResult = [[ORKTaskResult alloc] initWithIdentifier:@"taskResult"];
    taskResult.results = @[instructionStepResult, booleanStepResult];
    
    NSError *error;
    NSNumber *totalScore = [task totalScoreWithTaskResult:taskResult
                                         expressionFormat:@"instructionStep * booleanStep + 1"
                                                    error:&error];
    XCTAssertNil(error);
    XCTAssertEqual(totalScore.doubleValue, 5);
}

- (void)testIgnoreUnansweredQuestion {
    ORKStep *booleanStep = [ORKQuestionStep questionStepWithIdentifier:@"booleanStep"
                                                                 title:nil
                                                                answer:[ORKAnswerFormat booleanAnswerFormat]];
    booleanStep.staticScoreValue = 1;
    
    ORKFormItem *booleanFormItem = [[ORKFormItem alloc] initWithIdentifier:@"booleanFormItem"
                                                                      text:nil
                                                              answerFormat:[ORKAnswerFormat booleanAnswerFormat]];
    
    ORKFormStep *formStep = [[ORKFormStep alloc] initWithIdentifier:@"formStep" title:nil text:nil];
    formStep.formItems = @[booleanFormItem];
    
    formStep.staticScoreValue = 2;
    
    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:@"task"
                                                                steps:@[booleanStep, formStep]];
    
    ORKResult *booleanResult = [[ORKBooleanQuestionResult alloc] initWithIdentifier:@"booleanStep"];
    ORKStepResult *booleanStepResult = [[ORKStepResult alloc] initWithStepIdentifier:@"booleanStep"
                                                                             results:@[booleanResult]];
    
    ORKResult *booleanFormItemResult = [[ORKBooleanQuestionResult alloc] initWithIdentifier:@"booleanFormItem"];
    ORKStepResult *formStepResult = [[ORKStepResult alloc] initWithStepIdentifier:@"formStep"
                                                                          results:@[booleanFormItemResult]];
    
    ORKTaskResult *taskResult = [[ORKTaskResult alloc] initWithIdentifier:@"taskResult"];
    taskResult.results = @[booleanStepResult, formStepResult];
    
    NSError *error = nil;
    NSNumber *totalScore = [task totalScoreWithTaskResult:taskResult
                                         expressionFormat:nil
                                                    error:&error];
    XCTAssertNil(error);
    XCTAssertEqual(totalScore.doubleValue, 0);
}

@end
