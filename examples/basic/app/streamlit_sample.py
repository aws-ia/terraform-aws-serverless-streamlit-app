import streamlit as st
from PIL import Image

favicon = Image.open('assets/favicon/aws-custom-favicon-kdm.ico')

# Streamlit configuration
st.set_page_config(page_title="Streamlit App", page_icon=favicon, layout="centered", initial_sidebar_state="auto", menu_items=None)

st.title("Serverless Streamlit App with Terraform🚀")

# Create a column with two rows
col1, col2 = st.columns([0.1, 0.9])
with col1:
    st.image("assets/AWS_logo_RGB_REV.png", width=60)
    st.image("assets/tf-logo.png", width=60)
    # st.image("assets/assistant_logo.png", width=50)
with col2:
    st.text("You have successfully deployed a serverless Streamlit App with Terraform!")
    st.text("This solution uses VPC, ECS, Application Load Balancer, and CloudFront.")
    st.text("Continue to build your app and run 'terraform apply' to deploy changes.")


