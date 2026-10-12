# CloudKit production preparation

Verified October 11, 2026 for `iCloud.com.transfinite.MoodMargins`, owned by TRANSFINITE LLC (`88QL9VPLMY`).

## Current status

The main iPhone/iPad, Mac, and Vision app uses SwiftData automatic CloudKit mirroring through the first entitled container. `EZSwiftData.ModelContainerFactory` preserves SwiftData's default `cloudKitDatabase: .automatic` configuration. This synchronizes each person's journal through their private database; the app has no `CKShare` implementation or shared-database store. Watch entries remain local.

TestFlight and App Store distribution use the production CloudKit environment. Development builds retain their development environment. The app's source entitlements and persistence configuration did not need a production-only override.

**Production is deployed.** A read-only `cktool export-schema --environment production` on October 11 returned `CD_MoodEntry`, `CD_Activity`, the optional activity foreign key, and external-asset fields. The exported production schema exactly matches `CloudKitSchema.ckdb` (`cmp` passed). No journal records were queried, changed, or copied during this verification.

## Prepared changes

`CloudKitSchema.ckdb` is now the versioned schema exported back from the development container after a successful validated import. It contains:

- Existing `CD_MoodEntry` scalar fields and indexes.
- `CD_Activity`, including its ID, title, symbol, entity name, and `CD_moodEntry` string foreign key.
- External-asset fields for strings and serialized variable-length values.
- The unchanged `Users` type and existing access grants.

The actual SwiftData model types were compiled with Swift 6.4 and inspected through `NSManagedObjectModel.makeManagedObjectModel(for:)`. The optional activity relationship has a valid inverse and a one-to-many cardinality. Its foreign key belongs on `CD_Activity`, following [Apple's Core Data record mapping](https://developer.apple.com/documentation/coredata/reading-cloudkit-records-for-core-data). Existing data fields were preserved; no records were queried, reset, copied, or deleted through CloudKit management commands.

## Verification

- Development schema validation passed.
- `cktool import-schema --environment development --validate` succeeded.
- Exporting the deployed development schema confirmed both journal model record types and the added fields.
- The production validation endpoint returned `BadRequestException: endpoint not applicable in the environment 'production'`. It did not change production.
- An isolated initialization dry run using a temporary store could not reach the Mac CloudKit daemon (`Service Unavailable`). End-to-end device sync remains unverified. The dry run did not upload records or open the app's journal store.
- Application code, model definitions, and deployment targets are unchanged; no application rebuild was required for these server-schema changes.

## Device verification

The required Console promotion has been completed. Use TestFlight on two devices signed into the same iCloud account to verify creating, editing, and deleting a page, plus relaunch and offline recovery. Deployment copies the schema, not development journal records. Existing TestFlight builds can use the deployed schema without a new upload. Actual two-device sync remains unverified.
