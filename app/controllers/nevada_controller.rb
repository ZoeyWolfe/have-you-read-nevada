class NevadaController < ApplicationController
  def pdf
    send_file 'nevada.pdf'
  end

  def epub
    send_file 'nevada.epub'
  end

  def mobi
    send_file 'nevada.mobi.zip'
  end
end
