## E2E tests for SurrealDB

Since the testing story for SurrealDB at the moment is not quite extensive, this is an attempt to
test the most important functions in a community-driven way.


Ideas:
- tests can target different versions of SurrealDB (via ExUnit tags)
- tests run in isolated scope (fresh DB)
- tests focus mostly on correctness of the API / queries / etc, not so much performance / memory consumption
- tests make sure that upgrading to new version provides expected behaviour.