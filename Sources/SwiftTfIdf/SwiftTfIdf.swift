import NaturalLanguage
import Foundation

public class SwiftTfIdf {
    public var rawSentences = [String]()
    public var topN: Int
    public var stopWords: [String]
    
    init(text: String, stopWords: [String], topN: Int) {
        self.stopWords = stopWords
        self.topN = topN
        text.enumerateSubstrings(in: text.startIndex..., options: [.localized, .bySentences]) { (tag, _, _, _) in
            self.rawSentences.append(tag?.lowercased() ?? "")
        }
    }
    
    func sentences2ArrayOfWords(sentences: [String]) -> [[String]]{
        var arrayOfWordInSentences = [[String]]()

        let syncQueue1 = DispatchQueue(label: "level1")

        for sentence in sentences {
            var words = [String]()
            let tokenizer = NLTokenizer(unit: .word)
            tokenizer.string = sentence
            tokenizer.enumerateTokens(in: sentence.startIndex..<sentence.endIndex) { tokenRange, _ in
                let word = String(sentence[tokenRange])
                
                let syncQueue2 = DispatchQueue(label: "level2")

                for stopWord in self.stopWords {
                    if stopWord != word {
                        syncQueue2.sync {
                            words.append(word)
                        }
                    }
                }
                return true
            }

            syncQueue1.sync {
                arrayOfWordInSentences.append(words)
            }
        }
        return arrayOfWordInSentences
    }
    
    func calcTf(document: [String]) -> [String: Float] {
        var TF_dict = [String: Float]()

        for term in document {
            let isKeyExist = TF_dict[String(term)] != nil
            if isKeyExist {
                TF_dict[String(term)]! += 1
            } else {
                TF_dict[String(term)] = 1
            }
        }

        for (key, _) in TF_dict {
            TF_dict[String(key)] = TF_dict[String(key)]! / Float(document.count)
        }

        return TF_dict
    }

    func calcDF(tfDict: [[String: Float]]) -> [String: Float] {
        var countDF = [String: Float]()
        for document in tfDict {
            for term in document {
                let isKeyExist = countDF[term.key] != nil
                if isKeyExist {
                    countDF[term.key]! += 1
                } else {
                    countDF[term.key] = 1
                }
                
            }
        }
        return countDF
    }

    func calcIDF(nDocument: Int, df: [String: Float]) -> [String: Float] {
        var idfDict = [String: Float]()
        for term in df {
            idfDict[term.key] = logf(Float(nDocument) / (df[term.key]! + 1))
        }
        return idfDict
    }
    
    func calcTfIdf(TF: [String: Float], IDF: [String: Float]) -> [String: Float] {
        var tfIdfDict = [String: Float]()
        for term in TF {
            tfIdfDict[term.key] = TF[term.key]! * IDF[term.key]!
        }
        return tfIdfDict
    }


    func calcTFIDFVec(tfIdfDict: [String: Float], uniqueTerm: [String]) -> [Float] {
        var tfIdfVec = [Float]()
        for _ in 1...uniqueTerm.count {
            tfIdfVec.append(Float(0))
        }
        
        var initVal = 0
        for term in uniqueTerm {
            let isKeyExist = tfIdfDict[term] != nil
            if isKeyExist {
                tfIdfVec[initVal] = tfIdfDict[term]!
            }
            initVal += 1
        }
        return tfIdfVec
    }
    
    func finalCount() -> [(key: String, value: Float)] {
        let dictOfWordInSentences = sentences2ArrayOfWords(sentences: rawSentences)
        var dictOfTF = [[String: Float]]()
        let nDocument = dictOfWordInSentences.count
        var initValue = 0
        
        for document in dictOfWordInSentences {
            let tf_dict = calcTf(document: document)
            dictOfTF.append(tf_dict)
        }

        let dictOfDf = calcDF(tfDict: dictOfTF)
        _ = calcIDF(nDocument: nDocument, df: dictOfDf)

        var dictOfTFIDF = [[String: Float]]()

        for document in dictOfTF {
            dictOfTFIDF.append(calcTfIdf(TF: document, IDF: dictOfDf))
        }

        let sortedDF = dictOfDf.sorted {
            return $0.value > $1.value
        }
        
        // get topN
        var uniqueTerm = [String]()
        initValue = 0
        for term in sortedDF {
            if initValue > self.topN {
                break
            }
            uniqueTerm.append(term.key)
            initValue += 1
        }

        //vector
        var tfIdfVec = [[String: [Float]]]()
        initValue = 0
        for documents in dictOfTFIDF {
            var initVec = [String: [Float]]()
            for document in documents {
                initVec[document.key] = calcTFIDFVec(tfIdfDict: documents, uniqueTerm: uniqueTerm)
            }
            tfIdfVec.append(initVec)
            initValue += 1
        }

        var rawRanking = [String: Float]()
        for terms in tfIdfVec {
            var rankingValue: Float = Float(0.0)
            for dict in terms {
                for i in dict.value {
                    rankingValue += i
                }
                rawRanking[String(dict.key)] = rankingValue
            }
        }



        var ranking = [String: Float]()
        for i in uniqueTerm {
            let isKeyExist = rawRanking[i] != nil
            if isKeyExist {
                ranking[String(i)] = rawRanking[String(i)]
            }
        }

        let sortedRanking = ranking.sorted {
            return $0.value > $1.value
        }
        
        return sortedRanking
    }
    
}
