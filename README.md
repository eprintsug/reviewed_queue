# Reviewed items queue
This package creates a queue for reviewed items where publication of the metadata is pending an external trigger. This has arisen from the use case of datasets, where checking and validation of the content does not mean the record is ready to be published. Managing this from within the "Under Review" section becomes unwieldy, and there is a risk of items being missed for validation. The plugin provides an additional status, screen and actions to move an item to "reviewed" which allows repository managers to check an item's contents and then put it aside for future publication.

## Installation
The package is available through the [EPrints Bazaar](http://bazaar.eprints.org/id/eprint/494)

## Current version

The current version is 1.0.4 (21st June 2017)

## Files included

### /lib/epm/reviewed_queue/cfg/cfg.d/z_reviewed_queue.pl

Configuration settings which enable and map the plugins, add user permissions to admin to enable them to move items to review, and adds the reviewed dataset.

### /lib/lang/en/phrases/reviewed.xml

Phrases needed for rendering

### /lib/plugins/EPrints/Plugin/Screen/EPrint/UBMove.pm

Enables an eprint to be moved from buffer to reviewed and from reviewed to live archive.

### /lib/plugins/EPrints/Plugin/Screen/UBItems.pm

Ensures you can view Reviewed items in your own list of deposits

### /lib/plugins/EPrints/Plugin/Screen/UBReviewed.pm

Provides the screen listing reviewed items.

### /lib/plugins/EPrints/Plugin/Screen/UBStatus.pm

Includes reviewed in counts of eprints by status.

### /lib/plugins/EPrints/Plugin/UBEPrint.pm

Adds reviewed as a status and allows an authorised user to move items to that status.

### /lib/static/style/images/reviewed.png

Provides an icon in the Review screen to send an item to Reviewed.

### /lib/static/style/images/revert.png

Provides an icon in the Reviewed queue to send an item back to Review.