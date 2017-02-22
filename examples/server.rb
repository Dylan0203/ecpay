# frozen_string_literal: true
$LOAD_PATH << File.expand_path('../../lib', __FILE__)
require 'bundler/setup'
require 'sinatra'
require 'ecpay'

get '/' do
  @client = Ecpay::Client.new(mode: :test)
  @params = @client.generate_checkout_params(
    MerchantTradeNo: SecureRandom.hex(4),
    TotalAmount: 1000,
    TradeDesc: '交易測試',
    ItemName: '物品一#物品二',
    ReturnURL: 'https://requestb.in/127b0at1',
    ClientBackURL: 'https://requestb.in/127b0at1?inspect',
    ChoosePayment: 'Credit',
    PeriodAmount: 1000,
    PeriodType: 'D',
    Frequency: 1,
    ExecTimes: 12,
    PeriodReturnURL: 'https://requestb.in/127b0at1'
  )

  erb :index
end
