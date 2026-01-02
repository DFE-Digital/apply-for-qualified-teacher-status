# frozen_string_literal: true

module CSVStreamable
  BATCH_SIZE = 250

  private

  def set_csv_headers(filename:)
    response.headers["Content-Type"] = "text/csv"
    response.headers["Content-Disposition"] = "attachment; filename=#{filename}"
    response.headers["Cache-Control"] = "no-cache"
    response.headers["Last-Modified"] = Time.current.httpdate
  end

  def stream_csv(data:, csv_content_class:, batch_size: BATCH_SIZE)
    response.stream.write CSV.generate_line(csv_content_class.csv_headers)

    data.find_each(batch_size:) do |record|
      response.stream.write CSV.generate_line(csv_content_class.csv_row(record))
    end
  ensure
    response.stream.close
  end
end
