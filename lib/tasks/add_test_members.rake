task :generate_members => :environment do
	members = ['jim', 'bob', 'anna', 'shila', 'ashley', 'tim', 'johnny', 'marcus', 'reebar']

	for members.each do |m|
		p m
	end
end
