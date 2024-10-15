from google.cloud import container_v1
from google.api_core import exceptions<p></p>
<p>def disable_deletion_protection(project_id, location, cluster_name):
    client = container_v1.ClusterManagerClient()
    name = f"projects/{project_id}/locations/{location}/clusters/{cluster_name}"</p>
<pre><code>try:
    # Get the current cluster configuration
    cluster = client.get_cluster(name=name)

    # Update the deletion protection
    cluster.deletion_protection = False

    # Prepare the update mask
    update_mask = container_v1.types.FieldMask(paths=['deletion_protection'])

    # Send the update request
    operation = client.update_cluster(
        name=name,
        update=cluster,
        update_mask=update_mask
    )

    # Wait for the operation to complete
    operation.result()
    print("Deletion protection disabled successfully.")
except exceptions.GoogleAPICallError as e:
    print(f"Error disabling deletion protection: {e}")
</code></pre>
<h1>Replace these with your actual values</h1>
<p>project_id = "militaryknowledge"
location = "europe-west1"
cluster_name = "militaryknowledge-cluster"</p>
