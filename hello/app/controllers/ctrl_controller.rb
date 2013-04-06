# coding: utf-8
require 'kconv' # encoding周り

class CtrlController < ApplicationController
  def parameter
    text  = 'idパラメータ: '
    text += params[:id] ? params[:id] : 'undefined'
    render :text => text
  end

  # upload image file sample
  # 6.1.4
  def upload_process
    # アップロードファイルを取得
    file = params[:upfile]

    # ファイルのベース名(パスを除いた部分)を取得
    name = file.original_filename

    # 許可する拡張子を定義
    permits = ['.jpg', '.jpeg', '.gif', '.png']

    # 配列 permits にアップロードファイルの拡張子に合致するものがあるか
    if ! permits.include?(File.extname(name).downcase)
      render :text => "アップロードできるのは画像ファイルのみ( " + permits.join(', ') + " )です。"
    elsif file.size > 1.megabyte
      render :text => 'ファイルサイズは1MBまでです。'
    else
      # utf8 to sjis
      name = name.kconv(Kconv::SJIS, Kconv::UTF8)

      # /public/doc フォルダ配下にアップロードファイルを保存
      File.open("public/docs/#{name}", 'wb') { |f| f.write(file.read) }
      render :text => "#{name.toutf8}をアップロードしました。"
    end
  end
end
