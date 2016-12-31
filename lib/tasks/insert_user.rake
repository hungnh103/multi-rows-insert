namespace :insert_user do
  task :test => :environment do
    CONN = ActiveRecord::Base.connection
    TIMES = 50

    def do_inserts
      TIMES.times {User.create name: 'framgia', email:'framgia@demo.com'}
    end

    def raw_sql
      TIMES.times {CONN.execute "INSERT INTO users (name, email, created_at, updated_at)"+
        " VALUES('framgia', 'framgia@demo.com', '2016-12-28 06:14:01', '2016-12-28 06:14:01')"}
    end

    def mass_insert
      data = []
      TIMES.times do
        data.push "('framgia', 'framgia@demo.com', '2016-12-28 06:14:01', '2016-12-28 06:14:01')"
      end
      sql = "INSERT INTO users (name, email, created_at, updated_at) VALUES #{data.join(', ')}"
      CONN.execute sql
    end

    def activerecord_extensions_mass_insert validate = false
      columns = [:name, :email]
      values = []
      TIMES.times do
        values.push ['framgia', 'framgia@demo.com']
      end

      User.import columns, values, {validate: validate}
    end

    puts "Testing various insert methods for #{TIMES} inserts\n\n"
    print "*base* ActiveRecord without transaction: "
    start = Time.now.to_f
    do_inserts
    stop = Time.now.to_f
    base = stop.real - start.real
    puts "#{base} seconds\n\n"

    print "1/ ActiveRecord with transaction:"
    start = Time.now.to_f
    ActiveRecord::Base.transaction{do_inserts}
    stop = Time.now.to_f
    diff = stop.real - start.real
    puts sprintf("%2.2fx faster than base\n\n", base / diff)

    print "2/ Raw SQL without transaction: "
    start = Time.now.to_f
    raw_sql
    stop = Time.now.to_f
    diff = stop.real - start.real
    puts sprintf("%2.2fx faster than base\n\n", base / diff)

    print "3/ Raw SQL with transaction: "
    start = Time.now.to_f
    ActiveRecord::Base.transaction{raw_sql}
    stop = Time.now.to_f
    diff = stop.real - start.real
    puts sprintf("%2.2fx faster than base\n\n", base / diff)

    print "4/ Single mass insert: "
    start = Time.now.to_f
    mass_insert
    stop = Time.now.to_f
    diff = stop.real - start.real
    puts sprintf("%2.2fx faster than base\n\n", base / diff)

    printf "5/ ActiveRecord::Extensions mass insert: "
    start = Time.now.to_f
    activerecord_extensions_mass_insert
    stop = Time.now.to_f
    diff = stop.real - start.real
    puts sprintf("%2.2fx faster than base\n\n", base / diff)

    print "6/ ActiveRecord::Extensions mass insert without validations: "
    start = Time.now.to_f
    activerecord_extensions_mass_insert false
    stop = Time.now.to_f
    diff = stop.real - start.real
    puts sprintf("%2.2fx faster than base", base / diff)
  end
end
