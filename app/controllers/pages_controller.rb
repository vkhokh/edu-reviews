class PagesController < ApplicationController
  def home
    # Популярные курсы: сначала те, у которых больше всего отзывов.
    @courses = Course.includes(:teacher)
                     .left_joins(:reviews)
                     .group("courses.id")
                     .order(Arel.sql("COUNT(reviews.id) DESC"), :title)
                     .limit(4)
  end
end
