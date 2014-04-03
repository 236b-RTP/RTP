require 'time_utilities'

class TaskPlacer
  def initialize(tasks)
    @tasks = tasks
  end

  def order_tasks
    sep_tasks = separate_tasks(@tasks)
    final_order=[]
    while !sep_tasks.empty?
      max_scale = sep_tasks[0][1]
      best = sep_tasks.take_while { |e| e[1] >= max_scale }
      pref_order(best)
      sep_tasks -= best
      final_order += best
    end

    final_order
  end


  def pref_order(tasks)
    #tasks with sooner end dates come first
    tasks.sort!{|a,b| a[0].due_date.to_time <=> b[0].due_date.to_time}
  end

  def separate_tasks(tasks)
    #order = {1 => [], 2 => [], 3 => [], 4 => [], 5 => [], 6 => [], 7 => [], 8 => [], 9 => [], 10 => []}
    order = []
    tasks.each do |task|
      cur = Time.now - task.created_at.to_time
      fin = task.due_date.to_time - task.created_at.to_time
      o_num = task_scale(task.priority, cur, fin)
      #order[o_num] << [task]
      order << [task, o_num]
     end

    #order.sort.reverse
    order.sort{|a, b| b[1] <=> a[1] }
  end


  #I THINK I NEED AN ORIGIN TIME SINCE DUE AS A LENGHT OF TIME AWAY WILL CHANGE AND RERENDERING WILL CHANGE THE CURVE
  #DUE IS NOT THE DUE DATE BUT THE TIME FROM WHEN CREATED TO WHEN DUE

  def task_scale(p, elapsed, due)
    if p.between?(1, 5) && elapsed >= 0.0 && due >= elapsed && due > 0.0
      p_factor = -0.3 - ((p / 100.0) * p)
      #p_factor = -0.3
      d_factor = (10.0 - p) / due
      # base form out of ten not accounting priority 10-10e**(-0.5*(10/due)*today)
      # general form with priority p+(10-p)-(10-p)e**((-0.5-(p/100*p))*(10/due)*today)
      # alt (10-p / due) sqrt (due * current)
      scale = (10 - p) - ((10 - p) * (Math::E ** (p_factor * d_factor * elapsed))) + p + 1

      scale.to_i
    else
      raise ArgumentError
    end
  end
end