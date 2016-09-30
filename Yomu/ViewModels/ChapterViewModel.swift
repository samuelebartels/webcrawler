//
//  ChapterViewModel.swift
//  Yomu
//
//  Created by Sendy Halim on 7/6/16.
//  Copyright © 2016 Sendy Halim. All rights reserved.
//

import RxCocoa
import RxMoya
import RxSwift

struct ChapterViewModel {
  private let _chapter: Variable<Chapter>
  private let _previewUrl = Variable(ImageUrl(endpoint: ""))

  var previewUrl: Driver<URL> {
    return _previewUrl
      .asDriver()
      .filter { $0.endpoint.characters.count != 0 }
      .map { $0.url }
  }

  var title: Driver<String> {
    return _chapter.asDriver().map { $0.title }
  }

  var number: Driver<Int> {
    return _chapter.asDriver().map { $0.number }
  }

  var chapter: Chapter {
    return _chapter.value
  }

  init(chapter: Chapter) {
    _chapter = Variable(chapter)
  }

  func titleContains(pattern: String) -> Bool {
    return _chapter.value.title.lowercased().contains(pattern)
  }

  func fetchPreview() -> Disposable {
    let id = _chapter.value.id

    return MangaEden
      .request(MangaEdenAPI.chapterPages(id))
      .mapArray(ChapterPage.self, withRootKey: "images")
      .subscribe(onNext: {
        let sortedPages = $0.sorted {
          let (x, y) = $0

          return x.number < y.number
        }

        self._previewUrl.value = sortedPages.first!.image
      })
  }
}
