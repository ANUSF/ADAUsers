module UndertakingsHelper
  def datasets_to_collection(datasets)
    datasets.map { |dataset| [dataset.dataset_description, dataset.datasetID] }
  end

  def series_to_collection(series)
    series.map { |s| s.subjectId }
  end
end
