#!/bin/bash

Help()
{
cat << EOF
Assist tool to manage short-lived GCP tokens as used by hashicorp/google. See: https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/provider_reference#access_token

Examples:
  # Set new GOOGLE_OAUTH_ACCESS_TOKEN
  source gcp-token.sh -s
  . gcp-token.sh -s

  # Force renew GOOGLE_OAUTH_ACCESS_TOKEN
  source gcp-token.sh -f
  . gcp-token.sh -f

Options:
  -p  Prints the SHA1 of GOOGLE_OAUTH_ACCESS_TOKEN
  -h  Show this help message

Options that need to be prepended with . or source to take full effect:
  -s  Set GOOGLE_OAUTH_ACCESS_TOKEN with sane guardrails (stops you from overwriting)
  -f  Force a new token to be generated, overwriting any existing values

Usage:
  [source|.] gcp-token.sh [options]

Troubleshooting:
  There is a known issue where running the script with flags -f or -s returns no message, making it
  difficult to confirm if changes have taken place. This  can be mitigated by forcing the script to
  output a message such as the help prompt (either with -h or pass no parameters), and re-running
  again with the -f or -s parameter.
EOF
}

Set()
{
  if [ -z "${GOOGLE_OAUTH_ACCESS_TOKEN}"]; then
    GenerateAndSetPat
  else
    echo "Could not set GOOGLE_OAUTH_ACCESS_TOKEN as it already exists. Force with -f instead"
  fi

}

GenerateAndSetPat()
{
  PAT=$(gcloud auth print-access-token)

  export GOOGLE_OAUTH_ACCESS_TOKEN=$PAT

  echo "GOOGLE_OAUTH_ACCESS_TOKEN exported (SHA1=$(SHA $GOOGLE_OAUTH_ACCESS_TOKEN))"
}

SHA()
{
  echo $(echo -n $1 | sha1sum | awk '{print $1}')
}

Force()
{
  echo "Force renew GOOGLE_OAUTH_ACCESS_TOKEN"

  GenerateAndSetPat
}

Invalid()
{
  echo "Invalid parameters passed"
}

Print()
{
  if [ -z "${GOOGLE_OAUTH_ACCESS_TOKEN}" ]; then
    echo "GOOGLE_OAUTH_ACCESS_TOKEN is not set"
  else
    SHA $GOOGLE_OAUTH_ACCESS_TOKEN
  fi
}

while getopts "rfshp" option;
do
  case $option in
    r)  Reset
        ;;
    s)  Set
        ;;
    f)  Force
        ;;
    h)  Help
        exit;;
    p)  Print
        exit;;
    ?)  Help
        exit;;
  esac
done

if [ $OPTIND -eq 1 ]; then
  Help
fi
