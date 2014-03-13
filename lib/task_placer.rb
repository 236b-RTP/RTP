require 'pry'

class TaskPlacer
	#attr_accessor :
	def initialize()
	
	end
	#on equal checks 
	def get_best_task (tasks)
		if tasks.class = Array && !tasks.empty?
			prelim_o = order_tasks(tasks)
			best = prelim_o.take_while{|e| e>=prelim_o[0][1]}

			#DO THE PREFERENCE CHECKS TO ORDER
			#MAKE SURE TO TAKE THINGS WITH PRIOR DUE DATES BEFORE THINGS WITH = ORDER BUT LATER DATES


		else
			raise ArgumentError
		end
	end

	def order_tasks(tasks)
		order = []
		tasks.each do |task|
			o_num = task_order(task[:priority], Time.now-task[:start_time], task[:end_time]-task[:start_time])
			order<< [task, o_num]
		 end
		return order.sort.reverse

	end
	
	def task_order(p, elapsed, due)
		if p.between?(1,5) && elapsed>0 && due>=elapsed && due>0
			p_factor = -0.3-((p/100.0)*p)
			#p_factor = -0.3
			d_factor = (10.0-p)/due
			# base form out of ten not accounting priority 10-10e**(-0.5*(10/due)*today)
			# general form with priority p+(10-p)-(10-p)e**((-0.5-(p/100*p))*(10/due)*today)
			# alt (10-p / due) sqrt (due * current)
			t_order = (10-p)-((10-p)*(Math::E**(p_factor*d_factor*elapsed)))+p+1
			#binding.pry
			return t_order.to_i
		else
			raise ArgumentError
		end
	end
end

a = TaskPlacer.new
b = a.task_order(1, 30, 30)
puts b.to_s
b = a.task_order(5, 7, 9)
puts b.to_s


