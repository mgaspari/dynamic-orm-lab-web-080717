require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'interactive_record.rb'
require 'pry'

class Student < InteractiveRecord



  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names

    DB[:conn].results_as_hash = true
    sql = "PRAGMA table_info('#{table_name}')"
    r = DB[:conn].execute(sql)
    returnArray = []
    r.each do |values|
      returnArray << values['name']
    end
    returnArray.compact
  end

  self.column_names.each do |column_name|
    attr_accessor column_name.to_sym
  end

  def initialize(options={})
    options.each do |key, value|
      self.send("#{key}=", value)
    end
  end

  def table_name_for_insert
  self.class.table_name
end

  def col_names_for_insert
  self.class.column_names.delete_if {|col| col == "id"}.join(", ")
end

def values_for_insert
  values = []
  self.class.column_names.each do |col_name|
    values << "'#{send(col_name)}'" unless send(col_name).nil?
  end
  values.join(", ")
end

  def self.find_by_name(name)
    sql = "SELECT * FROM students WHERE name = ?"
    student = DB[:conn].execute(sql, name)
    # created = self.new(self.new_obj_format(student))
  end

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"

    DB[:conn].execute(sql)

    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]

  end

  def self.find_by(key_and_value)
    key = key_and_value.keys[0].to_s
    value = key_and_value[key.to_sym]
    sql = "SELECT * FROM students WHERE #{key} = ?"
    student = DB[:conn].execute(sql, value)
  end

  # def self.new_obj_format(array)
  #   str = ""
  #   self.column_names.each do |name, index|
  #   x =  "#{name}.to_sym #{array[index]}"
  #   str = "#{str} #{x}"
  #   end
  #   str
  #
  # end
end
