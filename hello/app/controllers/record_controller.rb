# coding: utf-8
class RecordController < ApplicationController

  # id に紐づく書籍情報を取得する
  def find
    @books = Book.find([2, 5, 10])
    # Note: view として views/hello/list.html.erb が使用される
    render 'hello/list'
  end

  # ActiveRecord#find_all_by_XXX
  def dynamic_find_all
    # SELECT "books".* FROM "books" WHERE "books"."publish" = '技術評論社'
    @books = Book.find_all_by_publish('技術評論社')
    render 'hello/list'
  end

  # ActiveRecord#find_all_by_XXX_and_XXX
  # Note: _and_ は使えるが _or_ は使えない
  def dynamic_find_all_and
    publish = '技術評論社'
    price   = 2604
    # SELECT "books".* FROM "books" WHERE "books"."publish" = '技術評論社' AND "books"."price" = 2604
    @books = Book.find_all_by_publish_and_price(publish, price)
    render 'hello/list'
  end

  # ActiveRecord#find_by_XXX
  def dynamic_find_and
    publish = '技術評論社'
    price   = 2604
    @book = Book.find_by_publish(publish, price)
    render 'books/show'
  end

  def where
    # Book.find_all_by_publish('技術評論社') と同等
    @books = Book.where(:publish => '技術評論社')

    # Book.find_all_by_publish_and_price('技術評論社', 2604)
    @books = Book.where(:publish => '技術評論社', :price => 2604)

    # SELECT "books".* FROM "books" WHERE ("books"."published" BETWEEN '2010-07-01' AND '2010-12-31')
    @books = Book.where(:published => '2010-07-01'..'2010-12-31')

    @books = Book.where(:publish => ['技術評論社', '翔泳社'])
    p @books
    render 'hello/list'
  end

  # プレースホルダ
  def placeHolder
    # 名前なしパラメータ
    where = 'publish = ? and price >= ?'
    @books = Book.where(where, params[:publish], params[:price])

    # 名前付きパラメータ
    where = 'publish = :publish and price >= :price'
    values = {
      :publish => params[:publish],
      :price   => params[:price],
     }
    p values

    @books = Book.where(where, values)
    p @books

    render 'hello/list'
  end

  # order by
  def order
    @books = Book.where(:publish => '翔泳社').order('price')
    @books = Book.where(:publish => '翔泳社').order('price desc')
    @books = Book.where(:publish => '翔泳社').order('publish desc, price desc')
    render 'hello/list'
  end

  # select
  def select
    # SELECT title,  price FROM "books" WHERE (price >= 2000)
    @books = Book.where('price >= 2000').select('title, price')
    render 'hello/list_select'
  end

  # limit offset
  def limit_offset
    @books = Book.order('published desc').limit(3).offset(4)
    render 'hello/list'
  end

  def page
    page_size = 3
    if (params[:id] == nil)
      page_num = 0
    else
      page_num = params[:id].to_i - 1
    end

    # record/page/4 とアクセスした場合は以下のクエリ
    # SELECT "books".* FROM "books" LIMIT 3 OFFSET 9
    @books = Book.limit(page_size).offset(page_size * page_num)
    render 'hello/list'
  end

  # first last
  def last
    @book = Book.order('price').first
    @book = Book.order('price').last
    render 'books/show'
  end

  # group by
  def group
    # later
  end

  # ActiveRecord#exists データが存在するかどうかを判定する
  def exists
    # where あり
    value = {:publish => '新評論社'}
    flag = Book.where(value).exists?

    # where なし
    value = 1
    flag = Book.exists?(value)

    value = ['price > ?', 5000]
    flag = Book.exists?(value)

    value = {:publish => '新評論社'}
    flag = Book.exists?(value)

    value = '1件でもデータ'
    flag = Book.exists?(value)
    render :text => "#{value} は存在するか? : #{flag}"
  end

  # Later:
  # 名前付きスコープ (よく使うものをまとめておける)
  # lambda を用いれば パラメータを渡すことも可能
  # default_scope メソッド => デフォルトで適応される条件などを記述しておく
  # # Note: これはやりすぎな気がする

  # count
  def count
    value = {:publish => '技術評論社'}
    cnt = Book.where(value).count
    render :text => "#{value} の件数は #{cnt}件"
  end

  # average max min sum
  def average
    # Later:
    # こんなノリ
    # prce_avg = Book.where(value).average('price')
  end

  # 生のSQL(非推奨)
  def find_by_sql
    query = [
      'select publish, avg(price) as avg_price',
      'from "books"',
      'group by publish',
      'having avg(price) >= ?',
    ].join(' ')
    # render :text => query
    price = 2500
    value = [query, price]
    p value
    @books = Book.find_by_sql(value)
    # @books = Book.find_by_sql(query)
    # debugger
    # render :text => @books
    render 'record/groupby'
  end

  def transact
    Book.transaction do
      value = {
        :isbn      => '978-4-7741-4223-0',
        :title     => 'Rubyポケットリファレンス',
        :price     => 2000,
        :publish   => '技術評論社',
        :published => '2011-02-01',
      }
      book1 = Book.new(value)
      # Note: save メソッドは boolean を返却するのに対して save! は例外を返却する
      book1.save!

      # 無理矢理例外を発生させるテスト
      raise 'Exeption occured: transaction is canceled'

      value = {
        :isbn      => '978-4-7741-4223-2',
        :title     => 'Tomcatポケットリファレンス',
        :price     => 2500,
        :publish   => '技術評論社',
        :published => '2011-03-01',
      }
      book2 = Book.new(value)
      book2.save!
    end
    render :text => 'Success transaction.'
    rescue => e
      render :text => e.message
  end

end
