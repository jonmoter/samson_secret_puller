Gem to read secrets generated by the puller.

 - When `/secrets` folder exists it will wait for it to be filled and then combine it's values with ENV
 - When `/secrets` folder does not exist it will assume that it is ran inside of a normal container and fallback to only reading from ENV.

```Ruby
require 'samson_secret_puller'
SECRETS = SamsonSecretPuller
secret = SECRETS['MY_FANCY_SECRET']
secret = SECRETS.fetch('MY_FANCY_SECRET')
```