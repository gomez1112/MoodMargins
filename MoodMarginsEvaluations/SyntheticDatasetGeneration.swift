//
//  SyntheticDatasetGeneration.swift
//  MoodMarginsEvaluations
//
//  Created by Gerard Gomez on 6/28/26.
//

import Foundation

#if canImport(Evaluations) && canImport(FoundationModels)
import Evaluations
import FoundationModels

@available(iOS 27.0, macOS 27.0, visionOS 27.0, watchOS 27.0, *)
enum SyntheticDatasetGeneration {
    static func expandedTagSamples(targetCount: Int = 40) -> AsyncThrowingStream<ModelSample<TagSuggestionExpected>, Error> {
        EvaluationSeedSamples.tagSuggestionSeeds.makeSamples(
            Prompt("""
            Generate realistic short diary entries and expected lowercase tags for a mood journal.
            Cover work, rest, family, social time, outdoors, tired days, calm days, and mixed emotions.
            Expected tags should be concise and should not include diagnosis or advice.
            """),
            targetCount: targetCount,
            validator: { sample in
                guard let expected = sample.expected else { return false }
                return EvaluationValidators.validTags(expected.tags)
            }
        )
    }

    static func expandedInsightSamples(targetCount: Int = 30) -> AsyncThrowingStream<ModelSample<InsightRecapExpected>, Error> {
        EvaluationSeedSamples.insightRecapSeeds.makeSamples(
            Prompt("""
            Generate compact mood-history snapshots and expected reflective recap cards.
            Include sparse and dense ranges, improving, declining, and steady trends, varied tags, and grounded non-diagnostic language.
            """),
            targetCount: targetCount,
            validator: { sample in
                guard let expected = sample.expected else { return false }
                return EvaluationValidators.validRecapFields(
                    title: expected.title,
                    pattern: expected.pattern,
                    supportingDetail: expected.supportingDetail,
                    gentleReflection: expected.gentleReflection,
                    nextPrompt: expected.nextPrompt
                )
            }
        )
    }

    static func insightGeneratorWithRejectedSamples(targetCount: Int = 30) -> SampleGenerator<ModelSample<InsightRecapExpected>> {
        SampleGenerator(
            Prompt("Generate grounded, non-diagnostic mood recap evaluation samples."),
            samples: EvaluationSeedSamples.insightRecapSeeds,
            targetCount: targetCount,
            samplingStrategy: .slidingWindow,
            validator: { sample in
                guard let expected = sample.expected else { return false }
                return EvaluationValidators.validRecapFields(
                    title: expected.title,
                    pattern: expected.pattern,
                    supportingDetail: expected.supportingDetail,
                    gentleReflection: expected.gentleReflection,
                    nextPrompt: expected.nextPrompt
                )
            }
        )
    }
}
#else
enum SyntheticDatasetGeneration {}
#endif
