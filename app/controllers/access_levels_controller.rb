class AccessLevelsController < ApplicationController
  def datasets_restricted
    # Original SQL:
    # $query_allB = "select datasetID,datasetname,fileContent from accesslevel join nesstar.StatementEJB on datasetID = nesstar.StatementEJB.objectId where (accessLevel='B' or accessLevel='S') and nesstar.StatementEJB.subjectId $series";

    # Note: This can be implemented as a single query with a join, but only in production (MySQL).
    # In development, we'd be joining across two separate sqlite databases, which isn't possible
    # to my knowledge.

    # TODO: If this is a performance issue, write a production environment-specific SQL query

    @series = params[:series]
    @datasets = AccessLevel.cat_b.includes(:series).select {|al| al.series and al.series.subjectId == @series}

    render :layout => false
  end

end
