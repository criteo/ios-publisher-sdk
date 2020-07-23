# Remove Created by
find . -iname *.h -o -iname *.m -o -iname *.swift | \
  xargs sed -i '' '/Created by/d'

# Edit Copyright
find . -iname *.h -o -iname *.m -o -iname *.swift | \
  xargs sed -i '' "s/Copyright.*Criteo/Copyright © 2018-$(date '+%Y') Criteo/g"
