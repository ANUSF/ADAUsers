module UndertakingsHelper
  def datasets_to_collection(datasets)
    datasets.map { |dataset| [dataset.dataset_description, dataset.datasetID] }
  end
end
