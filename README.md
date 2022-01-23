# Swift TF-IDF

> An ordinary swift package, have a bunch looping of calculating TFIDF and of course to ranking words.

## Install

Just install like usual, using swift package manager
1. `File` > `Add Packages...`
2. Paste `https://github.com/aziyan99/SwiftTfIdf` in the search form (top-right)
3. Choose the first one `SwiftTfIdf` with `main` branch

## How to use

Use it like usual, no magic here (magic will be add in the future :v)
1. import the package `import SwiftTfIdf`
2. Instance it `let tfIdf = SwiftTfIdf(text: String, stopWords: [String], topN: Int)`. **text** is the raw text that need to be ranking, **stopWords** the stop words (array of String), and **topN** how much the top words that want to get.
3. Call the `.finalCount()` function to get the results `let = results = tfIdf.finalCount()`. The funcion will returning array of dictionary `[(key: String, value: Float)]` with `key` is the words and `value` is ranking value.

## How it works

The calculation happend base on looping and sequentials, splitting the text to a bunch of array of sentences and words, calculate the tf, calculate the df and the tfidf, sorting the results, and ranking it. An example of implementation will be adding soon.
![looppp](https://i.redd.it/4npl9yfg5js11.jpg)

## Todo

- [ ] Writing the test case
- [ ] Adjust & improving the looping performance
- [ ] Restructuring the code
- [ ] Improve time complexity


## License

The Laravel framework is open-sourced software licensed under the [MIT license](https://opensource.org/licenses/MIT).

