class BaseGrid

  include Datagrid

  self.default_column_options = {
    # Uncomment to disable the default order
    # order: false,
    # Uncomment to make all columns HTML by default
    # html: true,
  }
  # Enable forbidden attributes protection
  # self.forbidden_attributes_protection = true

  def self.date_column(name, *args)
    block = lambda do |model|
      format(block_given? ? yield : model.send(name)) do |date|
        date&.strftime("%d.%m.%Y")
      end
    end
    if args.is_a?(Array) && args.length == 2
      column(name, args.first, **args.last, &block)
    elsif args.length == 0
      column(name, &block)
    else
      raise ArgumentError, "Invalid arguments"
    end
  end
end
