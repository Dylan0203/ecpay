# encoding: utf-8
# frozen_string_literal: true
require 'spec_helper'
require 'securerandom'

describe Ecpay::Client do
  before :all do
    @client = Ecpay::Client.new(mode: :test)
  end

  it '#api /Cashier/AioCheckOut/V2' do
    res = @client.request(
      '/Cashier/AioCheckOut/V2',
      MerchantTradeNo: SecureRandom.hex(4),
      MerchantTradeDate: Time.now.strftime('%Y/%m/%d %H:%M:%S'),
      PaymentType: 'aio',
      TotalAmount: 100,
      TradeDesc: '交易測試',
      ItemName: '物品一#物品二',
      ReturnURL: 'https://requestb.in/127b0at1',
      ClientBackURL: 'https://requestb.in/127b0at1?inspect',
      ChoosePayment: 'Credit'
    )

    expect(res.code).to eq '200'
    expect(res.body.force_encoding('UTF-8')).to include '物品一'
  end

  it '#api /Cashier/QueryTradeInfo/V2' do
    res = @client.request(
      '/Cashier/QueryTradeInfo/V2',
      MerchantTradeNo: '0457ce27',
      TimeStamp: Time.now.to_i
    )

    expect(res.code).to eq '200'
  end

  it '#query_trade_info' do
    result_hash = @client.query_trade_info '0457ce27'
    expect(result_hash.keys).to match_array %w(
      HandlingCharge ItemName MerchantID MerchantTradeNo PaymentDate
      PaymentType PaymentTypeChargeFee TradeAmt TradeDate TradeNo TradeStatus
      CheckMacValue
    )
  end

  it '#query_credit_card_period_info' do
    result_hash = @client.query_credit_card_period_info '0457ce27'
    expect(result_hash.keys).to match_array %w(
      MerchantID MerchantTradeNo TradeNo RtnCode PeriodType Frequency
      ExecTimes PeriodAmount amount gwsr process_date auth_code card4no
      card6no TotalSuccessTimes TotalSuccessAmount ExecLog ExecStatus
    )
  end

  it '#make_mac' do
    client = Ecpay::Client.new(
      merchant_id: '12345678',
      hash_key: 'ejCk326UnaZWKisg',
      hash_iv: 'q9jcZX8Ib9LM8wYk',
      mode: :test
    )

    mac = client.make_mac(
      ItemName: '商品',
      MerchantID: '12345678',
      MerchantTradeDate: '2017/02/22 12:00:00',
      MerchantTradeNo: 'ecpay_1234',
      PaymentType: 'ecpay',
      ReturnURL: 'https://localhost',
      TotalAmount: '500',
      TradeDesc: '交易測試'
    )

    expect(mac).to eq 'FB41AEDA372FCE19E05A574CD635FE2DD31F4ADC75082ABB8C6B43FC15E74B7F'
  end

  it '#verify_mac' do
    result = @client.verify_mac(
      RtnCode: '1',
      PaymentType: 'Credit_CreditCard',
      TradeAmt: '700',
      PaymentTypeChargeFee: '14',
      PaymentDate: '2017/02/22 12:21:00',
      SimulatePaid: '0',
      CheckMacValue: '3CC2573905D6AC52B6A92E55E1A64FF32EF7F14B335C998A4A7EFFB94F5C7451',
      TradeDate: '2017/02/22 12:20:00',
      MerchantID: '2000132',
      TradeNo: '1702221220478656',
      RtnMsg: '交易成功',
      MerchantTradeNo: '355313'
    )

    expect(result).to eq true
  end

  it '#verify_mac with more parameters' do
    result = @client.verify_mac(
      AlipayID: nil,
      AlipayTradeNo: nil,
      amount: '1290',
      ATMAccBank: nil,
      ATMAccNo: nil,
      auth_code: '777777',
      card4no: '2222',
      card6no: '431195',
      eci: '0',
      ExecTimes: nil,
      Frequency: nil,
      gwsr: '12303658',
      MerchantID: '2000132',
      MerchantTradeNo: 'R9710358221432568191',
      PayFrom: nil,
      PaymentDate: '2017/02/22 14:37:42',
      PaymentNo: nil,
      PaymentType: 'Credit_CreditCard',
      PaymentTypeChargeFee: '26',
      PeriodAmount: nil,
      PeriodType: nil,
      process_date: '2017/02/22 14:37:42',
      red_dan: '0',
      red_de_amt: '0',
      red_ok_amt: '0',
      red_yet: '0',
      RtnCode: '1',
      RtnMsg: '交易成功',
      SimulatePaid: '0',
      staed: '0',
      stage: '0',
      stast: '0',
      TenpayTradeNo: nil,
      TotalSuccessAmount: nil,
      TotalSuccessTimes: nil,
      TradeAmt: '1290',
      TradeDate: '2017/02/22 14:37:13',
      TradeNo: '1702221437131701',
      WebATMAccBank: nil,
      WebATMAccNo: nil,
      WebATMBankName: nil,
      CheckMacValue: '16711032F02312916507EBE0E0F44FD9A549A5A70BBAED6343CD05FC5CC30C31'
    )

    expect(result).to eq true
  end
end
