#  README

## General practices

Follow the Robert Martin suggestion about [Clean Code](https://gist.github.com/wojteklu/73c6914cc446146b8b533c0988cf8d29).

## Coding Style

There is a lack of coherency in the code base regarding the coding style. The cameleon style must not be applied here. All code that you touch must respect the following [Ray Wenderlich's coding style](https://github.com/raywenderlich/objective-c-style-guide).


## Testing

### Testing style
As much as possible, respect the ["Arrange, Act, Assert" convention](http://wiki.c2.com/?ArrangeActAssert) in the tests.

### Test organisation
The tests in this project are organised according to the following convention:
- Unit tests are located within the [test](src/test/) directory.
- Integration tests are written in the [Integration directory](/pubsdkTests/IntegrationTests)
- The subset of integration tests which represent one of the functional tests defined [here](https://confluence.criteois.com/display/EE/Functional+Tests)
 are post-fixed with `FunctionTests`. The rest are post-fixed with `IntegrationTests`.
