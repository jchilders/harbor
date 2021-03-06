module Harbor::ViewContext::Helpers::Html

  ##
  # Takes a flat array and yields the data properly separated into columns.
  ##
  def split_into_columns(data, columns) #:yields: column
    return if data.empty?

    per_column = (data.size / columns.to_f).ceil

    columns.times do |i|
      yield data[i*per_column, per_column]
    end
  end

  def split_into_groups(data, groups) #:yields: group
    return if data.empty?

    rows = (data.size / groups.to_f).ceil

    rows.times do |i|
      yield data[i*groups, groups]
    end
  end

end