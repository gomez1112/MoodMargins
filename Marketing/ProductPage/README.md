# MoodMargins custom product page and creative assets

Prepared October 11 and uploaded October 12, 2026 with the developer’s confirmation. All 24 images processed successfully in Apple’s Asset Library. All 30 placements and six screenshot sequences were verified by API readback. The custom page and default iOS version remain PREPARE_FOR_SUBMISSION drafts. No review submission or keyword routing change was made. [Deployment.json](Deployment.json) records the resource IDs and verification results.

[View the complete artwork](ContactSheet.png). The header and search previews on that sheet are crops of Apple’s focal safe areas, not screenshots of Apple’s product-page Preview tool. Full upload files are linked below.

## Creative direction

The notebook illustration matches the shipped icon. Cream paper, blush, lavender, sky, and plum connect the artwork to the app. The header offers one quiet brand message. Search shows the actual Today interface, including mood selection and a journal page, so people can recognize the purpose quickly.

All text is localized in English, Spanish, and Arabic. Arabic compositions place the message on the right and the visual on the left. The creative assets use an unaltered crop of a real app capture; the notebook is the existing icon foreground. The custom-page screenshots show the actual native iPhone and iPad interfaces.

## Upload files

| Locale | Product-page header | Search-results asset |
| --- | --- | --- |
| English | [header.png](en-US/header.png) | [search.png](en-US/search.png) |
| Spanish | [header.png](es-ES/header.png) | [search.png](es-ES/search.png) |
| Arabic | [header.png](ar-SA/header.png) | [search.png](ar-SA/search.png) |

Headers are 3840 × 1646 pixels. Search artwork is 3840 × 2560 pixels. All final files are 8-bit sRGB RGB PNGs without alpha. The image specifications and accepted placement groups were checked against Apple’s live Asset Library reference data.

The `Review/` images are focal-area crops for inspection and must not be uploaded as final artwork. [AssetManifest.json](AssetManifest.json) lists all 24 final files, dimensions, sizes, SHA-256 checksums, categories, placement groups, and accepted specification IDs. [AppleSpecifications.json](AppleSpecifications.json) records the relevant live reference data.

## Custom page: Daily check-ins

The page focuses on a small daily reflection rather than premium themes. Three distinct screenshots tell the story in order:

1. Choose a mood on Today.
2. See mood patterns in Insights.
3. Revisit the automatically saved page.

Each language includes three iPhone screenshots at 1320 × 2868 and three iPad screenshots at 2064 × 2752. The full app UI fits within each frame. The same six creative images can be reused for both the default iOS page and this custom page, without duplicating their uploads. [PagePlan.json](PagePlan.json) contains the exact scope and localized promotional text.

English promotional text:

> Start with one mood and a few words. Your pages save automatically. Explore mood trends, your most common mood, and your longest journaling streak.

Spanish promotional text:

> Empieza con un ánimo y unas palabras. Tus páginas se guardan automáticamente. Descubre tendencias, tu ánimo más frecuente y tu racha más larga.

Arabic promotional text:

> ابدأ بشعور واحد وبضع كلمات. تُحفظ صفحاتك تلقائيًا. اكتشف اتجاهات مزاجك وشعورك الأكثر شيوعًا وأطول سلسلة تدوين لديك.

The name and subtitle are inherited from the app listing. Keyword routing is deferred until an approved app version and approved custom page exist; Apple requires choosing from approved version keywords. No deep link or ad campaign is part of this package.

## Completed App Store Connect action

Created one custom product page named **Daily check-ins**, added its three localized promotional texts, uploaded the 24 final images, and placed them as described in PagePlan.json:

- Default iOS version 1.0: one header and one search-results image per localization.
- New custom page: reuse the header and search image per localization, plus three screenshots for each of iPhone and iPad.
- Saved the results as drafts and verified processing and placement order.

The custom page’s ID is `40507614-2637-4477-928c-7ca0ce4b682d`. No current screenshots or previews were deleted. The default listing’s 81 screenshots and nine videos remain outside this batch. Apple requires the custom page to be reviewed before it appears to customers; a first-release custom page goes with the initial iOS version’s review submission. [Apple-generated page URL](https://apps.apple.com/us/app/moodmargins/id6819079849?ppid=40507614-2637-4477-928c-7ca0ce4b682d). The URL is not evidence of a public release.

Header/search assets are the new iOS 27 and iPadOS 27 creative placements; they are separate from Mac, Watch, and Vision screenshot sets. Draft uploads become visible only after the appropriate Apple approval and release.

## Verification

All 24 final exports match Apple’s current image catalog, placement groups, maximum file size, and alpha requirements. Apple’s processed dimensions and specification IDs match every expected file. Placements report ACTIVE, meaning they are attached to their parent drafts; both parent states were separately verified as PREPARE_FOR_SUBMISSION. The 147-, 143-, and 115-character promotional texts fit the 170-character limit. Apple’s Photoshop templates supplied these focal bounds:

| Asset | Focal safe area: x, y, width, height |
| --- | --- |
| Header | 1097, 493, 1646, 661 |
| Search | 836, 765, 2168, 1030 |

The design stays within these bounds for the essential text and imagery. Peripheral page outlines are decoration. Artwork has no prices, discounts, URLs, awards, medical claims, or third-party platform logos. Captures contain fictional journal content from the isolated marketing store.

## Reproduce

Run from the project directory using the installed Xcode toolchain:

```sh
xcrun swift -swift-version 6 -default-isolation MainActor -module-cache-path /private/tmp/MoodMargins-Marketing-Modules Tools/Marketing/RenderProductPageAssets.swift .
xcrun swift -swift-version 6 -default-isolation MainActor -module-cache-path /private/tmp/MoodMargins-Marketing-Modules Tools/Marketing/ProductPageContactSheet.swift Marketing/ProductPage
python3 Tools/Marketing/ValidateProductPageAssets.py
```

The validator checks file hashes and Apple’s captured specifications without contacting App Store Connect. After deliberately changing and inspecting an export, use its `--write-manifest` option to record the new hashes. Re-check the live catalog before uploading.

Apple’s templates were downloaded for inspection into a temporary directory and are not redistributed in this repository.

## Official references

- [Apple’s asset best practices](https://developer.apple.com/app-store/asset-best-practices/)
- [Creative asset specifications](https://developer.apple.com/help/app-store-connect/reference/app-information/creative-assets-specifications)
- [Manage your App Store assets](https://developer.apple.com/help/app-store-connect/manage-app-information/manage-your-app-store-assets)
- [Custom product page configuration](https://developer.apple.com/help/app-store-connect/create-custom-product-pages/configure-multiple-product-page-versions)
- [Submit a custom product page](https://developer.apple.com/help/app-store-connect/manage-submissions-to-app-review/submit-a-custom-product-page)
- [App Asset Library API](https://developer.apple.com/documentation/appstoreconnectapi/app-asset-library)

