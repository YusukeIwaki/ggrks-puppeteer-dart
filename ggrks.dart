import 'dart:io';

import 'package:puppeteer/puppeteer.dart';

extension IterableExtension<T> on Iterable<T> {
  firstOrNull() {
    if (this.isEmpty) {
      return null;
    } else {
      return this.first;
    }
  }
}

extension StringExtension on String {
  ifEmpty(String defaultValue) {
    if (this.isEmpty) {
      return defaultValue;
    } else {
      return this;
    }
  }
}

main(List<String> args) async {
  final String searchKeyword = args.join(" ").ifEmpty("puppeteer");

  final browser = await puppeteer.launch(
    // MacにインストールされているChromeを使う。
    executablePath: Platform.environment['PUPPETEER_EXECUTABLE_PATH'] ??
        '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',

    // ブラウザ画面を表示しながら（ヘッドレスモードを無効にする）。
    headless: false,

    args: [
      // ゲストセッションで操作する。
      "--guest",

      // ウインドウサイズをデフォルトより大きめに。
      '--window-size=1280,800',
    ],

    // 人間味のある速度で入力/操作する。
    slowMo: Duration(milliseconds: 50),
  );

  // 大抵のサンプルコードはここで単純に browser.newPage() しているだけのものが多いが、
  // ブラウザを開いたときにすでに１つタブが開いている場合には、２つ目のタブが開いてしまう。
  // それを防ぐため、すでにタブが開いている場合にはそれを使うようにする。
  final Page page =
      (await browser.pages).firstOrNull() ?? (await browser.newPage());

  await page.setViewport(DeviceViewport(width: 1280, height: 800));

  await page.goto("https://google.com/");
  await page.type("input[name='q']", searchKeyword);
  await page.keyboard.press(Key.enter);

  // 3秒後に閉じる。
  await Future.delayed(Duration(seconds: 3));
  await browser.close();
}
