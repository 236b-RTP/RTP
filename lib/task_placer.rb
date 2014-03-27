require 'pry'

class TaskPlacer
	#attr_accessor :
	def initialize()
	
	end
	#on equal checks 
	def order_tasks (tasks)
		if tasks.class == Array && !tasks.empty? #changed this to be == from =
			sep_tasks = sep_tasks(tasks)
			final_order=[]
			while !sep_tasks.empty?
				max_scale = sep_tasks[0][1]
				best = sep_tasks.take_while{|e| e[1]>=max_scale}
				pref_order(best)
				sep_tasks-=best
				final_order+=best
			end
			return final_order
		else
			raise ArgumentError
		end
	end
	
	
	def pref_order(tasks)
		#tasks with sooner end dates come first
		tasks.sort!{|a,b| a[:due_date].to_time<=>b[:due_date].to_time}
	end

	def sep_tasks(tasks)

		#order = {1 => [], 2 => [], 3 => [], 4 => [], 5 => [], 6 => [], 7 => [], 8 => [], 9 => [], 10 => []}
		order = []
		tasks.each do |task|
			cur = Time.now - task[:created_at].to_time
			fin = task[:due_date].to_time - task[:created_at].to_time
			o_num = task_scale(task[:priority], cur, fin)
			#order[o_num]<< [task]
			order<<[task, o_num]
		 end
		#return order.sort.reverse
		return order.sort{|a, b| b[1]<=>a[1]}

	end
	

	#I THINK I NEED AN ORIGIN TIME SINCE DUE AS A LENGHT OF TIME AWAY WILL CHANGE AND RERENDERING WILL CHANGE THE CURVE
	#DUE IS NOT THE DUE DATE BUT THE TIME FROM WHEN CREATED TO WHEN DUE

	def task_scale(p, elapsed, due)
		puts p.to_s
		puts elapsed.to_s
		puts due.to_s
		if p.between?(1,5) && elapsed>=0.0 && due>=elapsed && due>0.0
			p_factor = -0.3-((p/100.0)*p)
			#p_factor = -0.3
			d_factor = (10.0-p)/due
			# base form out of ten not accounting priority 10-10e**(-0.5*(10/due)*today)
			# general form with priority p+(10-p)-(10-p)e**((-0.5-(p/100*p))*(10/due)*today)
			# alt (10-p / due) sqrt (due * current)
			scale = (10-p)-((10-p)*(Math::E**(p_factor*d_factor*elapsed)))+p+1
			#binding.pry
			return scale.to_i
		else
			raise ArgumentError
		end
	end
end

a = TaskPlacer.new
today = DateTime.now
tomorrow = DateTime.now + (60*60*24)
start = DateTime.now
finishTime = DateTime.now + (60*60*2)
c = a.order_tasks([{title: "hello", start_time: start, end_time: finishTime, priority: 3 , created_at: today, due_date: tomorrow}, {title: "hello2*****", start_time: start, end_time: finishTime, priority: 1 , created_at: today, due_date: tomorrow}])
puts c.to_s
