[![Gem Version](https://badge.fury.io/rb/ecpay_client.svg)](https://badge.fury.io/rb/ecpay_client)
[![Build Status](https://travis-ci.org/CalvertYang/ecpay.svg?branch=master)](https://travis-ci.org/CalvertYang/ecpay)

# Ecpay 綠界

這是綠界 API 的 Ruby 包裝，更多資訊參考他們的[官方文件](https://www.ecpay.com.tw/Content/files/ecpay_011.pdf)。

- 這不是 Rails 插件，只是個 API 包裝。
- 使用時只需要傳送需要的參數即可，不用產生檢查碼，`ecpay_client` 會自己產生。
- 感謝[大兜](https://github.com/tonytonyjan)撰寫的 [allpay](https://github.com/tonytonyjan/allpay)

## 安裝

```bash
gem install ecpay_client
```

## 使用

```ruby
test_client = Ecpay::Client.new(mode: :test)
production_client = Ecpay::Client.new({
  merchant_id: 'MERCHANT_ID',
  hash_key: 'HASH_KEY',
  hash_iv: 'HASH_IV'
})

test_client.request(
  '/Cashier/QueryTradeInfo',
  MerchantTradeNo: '0457ce27',
  TimeStamp: Time.now.to_i
)
```

本文件撰寫時，綠界共有 8 個 API (全方位金流介接技術文件 V2.0.6)：

Endpoint                            | 說明
---                                 | ---
/Cashier/AioCheckOut/V2             | 產生訂單
/Cashier/QueryTradeInfo/V2          | 查詢訂單
/Cashier/QueryCreditCardPeriodInfo  | 信用卡定期定額訂單查詢
/CreditDetail/DoAction              | 信用卡關帳/退刷/取消/放棄
/Cashier/Capture                    | 合作特店申請撥款
/PaymentMedia/TradeNoAio            | 下載合作特店對帳媒體檔
/CreditDetail/QueryTrade/V2         | 查詢信用卡單筆明細記錄
/CreditDetail/FundingReconDetail    | 下載信用卡撥款對帳資料檔

詳細 API 參數請參閱綠界金流介接技術文件，注意幾點：

- 使用時不用煩惱 `MerchantID` 與 `CheckMacValue`，正如上述範例一樣。
- `/Cashier/AioCheckOut/V2` 回傳的內容是 HTML，這個請求應該是交給瀏覽器發送的，所以不應該寫出 `client.request '/Cashier/AioCheckOut/V2'` 這樣的程式碼。

## Ecpay::Client

實體方法                                                      | 回傳                 | 說明
---                                                          | ---                 | ---
`request(path, **params)`                                    | `Net::HTTPResponse` | 發送 API 請求
`make_mac(**params)`                                         | `String`            | 用於產生 `CheckMacValue`，單純做加密，`params` 需要完整包含到 `MerchantID`
`verify_mac(**params)`                                       | `Boolean`           | 用於檢查收到的參數，其檢查碼是否正確，這用在綠界的 `ReturnURL` 與 `PeriodReturnURL` 參數上。
`query_trade_info(merchant_trade_number, platform = nil)`    | `Hash`              | `/Cashier/QueryTradeInfo/V2` 的捷徑方法，將 `TimeStamp` 設定為當前時間
`query_credit_card_period_info(merchant_trade_number)`       | `Hash`              | `/Cashier/QueryCreditCardPeriodInfo` 的捷徑方法，將 `TimeStamp` 設定為當前時間
`generate_checkout_params`                                   | `Hash`              | 用於產生 `/Cashier/AioCheckOut/V2` 表單需要的參數，`MerchantTradeDate`、`MerchantTradeNo`、`PaymentType`，可省略。

## 使用範例

```bash
git clone git@github.com:CalvertYang/ecpay.git
cd ecpay
bundle install
ruby examples/server.rb
```
